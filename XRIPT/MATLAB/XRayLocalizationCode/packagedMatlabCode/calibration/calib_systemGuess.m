function [systemDeltas, exitflag] = calib_systemGuess(oldExpectedSystem, calibrationPattern, RHS)

%%calib_systemGuess: returns a set of systemDeltas to use as an initial guess for calib_calibrate
% 
% [systemDeltas, exitflag] = calib_systemGuess(oldExpectedSystem,
% RHS)
%
% This is only called by calib_calibrate- uses a linear method as described
% in Trucco to get f, ox, oy, R, T. Then converts these parameters to
% systemDeltas used as an improved initial guess for calib_calibrate. 
% THis method is not striclty necessary, but it makes calibration converge
% in much fewer iteration, and to a slightly better solution than with just
% the iterative method
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
% oldExpectedSystem  is a guess at the state of the system that we input to calibration. (see System Guess)
%
% CalibrationPattern is an n*3 array of centerpoints as determined by CT data extraction (see CT Data Extraction). 
%
% RHS is a vector of extracted features from images of the calibration object (see Feature Extraction). 
% The order of the extracted features must be the same as the order of the
% calibration pattern.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
% systemDeltas- the set of systemDeltas that almost solves calibration. In
% the absence of noise, systemDeltas is the precise calibration solution. 
%
% exitFlag: indicates whether calibration converged. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires:
% calibration pattern and calibration RHS have the same ordering
% of fiducials
%
% System guess contains correct information about the type of detector that
% is passed in, as well as the number of detectors- if the RHS was formed
% using a 1000*1024 detector, than passing in an XRAYSystem that contains
% 500*512 detectors will yield the wrong solution. 
%
% Modifies: expectedSytem from initial state untill its output matches RHS

%%debug output
displ = 1;

xrg_emptySystem(oldExpectedSystem);
xrg_addFiducials(oldExpectedSystem, calibrationPattern);

numDetectors = oldExpectedSystem.getNumberOfSDP();

for i=1:numDetectors
    
    %% the calls to generate guess solve for a set of parameters to describe
    %% the perturbations on our system(using truccos linear method). However these params are in a different
    %% reference frame than the one we are using in iterative calibration code
    [f{i}, ox{i}, oy{i}, R{i}, T{i}] = generateGuess(oldExpectedSystem, RHS, i);
end

%%converting to systemDeltas frame
[systemDeltas, exitflag] = cameraFrameToSystemDeltas(oldExpectedSystem, f, ox, oy, R, T) %%converting the camera frame parameters into system deltas in dans frame
end




%%f, ox, oy, R, and T are array of paramters- one for every sdp in
%% oldExpectedSystem
%% this function converts camera frame params into systemdeltas in dans
%% frame. USes an iterative method to solve for system deltas
function[systemDeltas, exitflag] = cameraFrameToSystemDeltas(oldExpectedSystem, f, ox, oy, R, T)

displ = 1;
%%converting to a world frame
for i =1:oldExpectedSystem.getNumberOfSDP()
    [detCenter{i}, srcCenter{i}, detectorRowDirection{i}, detectorColDirection{i}] = ...
        cameraToWorld(oldExpectedSystem, i, f{i}, ox{i}, oy{i}, R{i}, T{i});
end

%%getting a transfromation to convert from world frame to DanFrame- x axis
%%along sdp1 line, etc
[RDan, TDan] = ...
    worldToDanFrame(oldExpectedSystem,...
                    srcCenter{1},...
                    detCenter{1},...
                    detectorRowDirection{1},...
                    detectorColDirection{1});

%converting all the SDPs into Danframe
numDetectors = oldExpectedSystem.getNumberOfSDP();
for i = 1:numDetectors       
    srcCenter{i} = RDan * srcCenter{i} + TDan;
    detCenter{i} = RDan * detCenter{i} + TDan;
    detectorRowDirection{i}   = RDan * detectorRowDirection{i}; %%basis vectors arent translated
    detectorColDirection{i}   = RDan * detectorColDirection{i}; %%basis vectors arent translated
end

%%converting the calibration pattern into Danframe
points = xrg_getFiducialCenters(oldExpectedSystem);
points = points';

for i=1:size(points,2)
    points(:,i) = RDan*points(:,i)+TDan;
end

%%forming a single vector to describe the danframe params
danFrameValues(1) = detCenter{1}(1);
danFrameValues(2) = detectorRowDirection{1}(1);
danFrameValues(3) = detectorRowDirection{1}(2);
danFrameValues(4) = detectorRowDirection{1}(3);
danFrameValues(5) = detectorColDirection{1}(1);
danFrameValues(6) = detectorColDirection{1}(2);
danFrameValues(7) = detectorColDirection{1}(3);
offset = 7;

for i = 2:numDetectors
    danFrameValues(1  + offset + (i-2)*12)  = srcCenter{i}(1);
    danFrameValues(2  + offset + (i-2)*12)  = srcCenter{i}(2);
    danFrameValues(3  + offset + (i-2)*12)  = srcCenter{i}(3);
    danFrameValues(4  + offset + (i-2)*12)  = detCenter{i}(1);
    danFrameValues(5  + offset + (i-2)*12)  = detCenter{i}(2);
    danFrameValues(6  + offset + (i-2)*12)  = detCenter{i}(3);

    danFrameValues(7  + offset + (i-2)*12) = detectorRowDirection{i}(1);
    danFrameValues(8  + offset + (i-2)*12) = detectorRowDirection{i}(2);
    danFrameValues(9  + offset + (i-2)*12) = detectorRowDirection{i}(3);
    danFrameValues(10 + offset + (i-2)*12) = detectorColDirection{i}(1);
    danFrameValues(11 + offset + (i-2)*12) = detectorColDirection{i}(2);
    danFrameValues(12 + offset + (i-2)*12) = detectorColDirection{i}(3);
end
% danFrameValues
% error('done')

offset2 = offset+12*(numDetectors-1);
for i=1:size(points,2) 
    danFrameValues(offset2 + 3*(i-1) + 1) = points(1,i);
    danFrameValues(offset2 + 3*(i-1) + 2) = points(2,i);
    danFrameValues(offset2 + 3*(i-1) + 3) = points(3,i);
end

% size(danFrameValues)
% danFrameValues
% error('done')

%% using an iterative method to solve for param deltas relative to the old
%% expected system- perturbs oldexpectedSystem untill detector center,
%% source center, detector row directoin and detector col direction match
%% the actual values vector

global guesser

%%defining the F that we are going to solve via an iterative method
guesser = Simulator.ParamGuesser(oldExpectedSystem, danFrameValues);
fun = @calcF;

[complex, guess] = xrg_getSystemDeltas(oldExpectedSystem);

if(displ)
    showIterations = 'iter';
else
    showIterations = 'off';
end

options = optimset('Display', showIterations,'LargeScale','off', 'LevenbergMarquardt', 'on', 'MaxFunEvals', 100000000,...
    'TolFun', 10^-15, 'TolCon', 10^-15, 'MaxIter', 100);


%%solving for the set of system deltas that will perturb the old
%%expected system to get a system wth same geometry as danframeValues
[systemDeltas,resnorm,residual,exitflag,output] = ...
    lsqnonlin(fun,... %%function we are minimizing
    guess,...
    [],...
    [],...
    options);

% systemDeltas
end




function F = calcF(X)
global guesser
F = guesser.calcF(X);
end


%%This is a linear method for finding a set of parameters to describe one
%% sdp

%%see Trucco, chapter 6 for explanation of algorithm
%%acutal values is an RHS vector

%%f is the focal distance of the sdp, ox is the x pixel coordinate of the center of projection
%%oy is y pixel coordinate of the center of projection, R is the extrinsic Rotation
%%required to bring the fiducials into the sdpIndxth sdp's camera frame., T is the extrinsic translation 
function [f, ox, oy, R, T] = generateGuess(expectedSystem, actualValues, sdpIndex)

dataPerArray = expectedSystem.availableData(1)/expectedSystem.getNumberOfSDP();


reformattedActualValues = actualValues((sdpIndex-1)*dataPerArray + 1:(sdpIndex*dataPerArray));

A = formMatrix(expectedSystem, reformattedActualValues);

pixelSize = xrg_getPixelSize(expectedSystem, sdpIndex);
pixelWidth = pixelSize(2);

[f, ox, oy, R, T] = getParams(A, pixelWidth);
end


function [A] = formMatrix(expectedSystem, values)
fc = expectedSystem.getFids().getFiducialCollection();
fids = fc.getNumberOfFiducials();
A = zeros(fids, 12);
for calibFiducial = 1:fids
    %%careful here!
    position = fc.getFiducialLocation(calibFiducial-1);

    X = position.x; %%world position x
    Y = position.y; %%world position y
    Z = position.z; %%world position z

    x = values(2*(calibFiducial-1)+1); %%image position x
    y = values(2*(calibFiducial-1)+2); %% image position y

    A(calibFiducial*2-1,1)  = X;
    A(calibFiducial*2-1,2)  = Y;
    A(calibFiducial*2-1,3)  = Z;
    A(calibFiducial*2-1,4)  = 1;
    %%a bunch of zeros left in betweeen
    A(calibFiducial*2-1,9)  = -x*X;
    A(calibFiducial*2-1,10) = -x*Y;
    A(calibFiducial*2-1,11) = -x*Z;
    A(calibFiducial*2-1,12) = -x;

    %%zeros left to start next row, and then...
    A(calibFiducial*2, 5)  = X;
    A(calibFiducial*2, 6)  = Y;
    A(calibFiducial*2, 7)  = Z;
    A(calibFiducial*2, 8)  = 1;
    %%a bunch of zeros left in betweeen
    A(calibFiducial*2, 9)  = -y*X;
    A(calibFiducial*2, 10) = -y*Y;
    A(calibFiducial*2, 11) = -y*Z;
    A(calibFiducial*2, 12) = -y;
end
end

%%solve for the pertubations from true postion to camera position
function [f, ox, oy, R, T] = getParams(A, pixelWidth);
%%pixelWidth
%%'svd is'
[U, S, V] = svd(A);
%%the column closest to the solution of A*M = 0, wehre M is in column form
lastCol = size(V,2);
nullColumn = V(:,lastCol);
M = reshape(nullColumn,4,3)'; %reshaping into projection matrix for clarity
%%eigVal = S(lastCol, lastCol)
%%pause
gamma = norm(M(3,1:3));

%%normalizing
M = M/gamma;

q1 = (M(1,1:3))';
q2 = (M(2,1:3))';
q3 = (M(3,1:3))';
q4 = (M(1:3,4));

ox = q1'*q3;
oy = q2'*q3;
fx = ((q1'*q1)-ox^2)^.5;
fy = ((q2'*q2)-oy^2)^.5;
f = fx*pixelWidth;
R(3,1:3) = M(3,1:3);
T(3,1) = M(3,4);

%%M 
R(1,1:3) = (ox*M(3,1:3)-M(1,1:3))/fx;
R(2,1:3) = (oy*M(3,1:3)-M(2,1:3))/fy;
%ox, oy, M(1,4), M(2,4)
T(1,1) = (ox*T(3,1)-M(1,4))/fx;
T(2,1) = (oy*T(3,1)-M(2,4))/fy;
% R
% pause

[U, S, V] = svd(R); 
S = eye(3);
R = U*S*V';

if (M(3,4)<0)
    R = -R;
    T = -T;
end


end


%%converts the geometry of an sdp as described by f, ox, oy, R, T, (and detector pixel dimensions and pixel sizes as contained within expected system)
%%into an abstract world frame. 
function [detCenter,...
          srcCenter,...
          detectorRowDirection,...
          detectorColDirection] = ...
          ...
    cameraToWorld(expectedSystem, sdpIndex, f, ox, oy, R, T)

%%loading some values first
Rinverse = inv(R);
rowcol = xrg_getDetectorSize(expectedSystem, sdpIndex);
rows = rowcol(1); %%rows in the expectedDetector
cols = rowcol(2); %%cols in the expectedDetector
heightWidth = xrg_getPixelSize(expectedSystem, sdpIndex);
pixelHeight = heightWidth(1); %%pixel height
pixelWidth  = heightWidth(2); %%pixel width



%%Detector calculations
%%applying intrinsic paramters of camera frame
%%perturbing the center of the detector in the x and y direction of camera reference frame, 
%%and also adding focal length (z direction)
detectorCenterPixelCoordinatesX = cols/2;
detectorCenterPixelCoordinatesY = rows/2;

detCenterX = -(cols/2-ox) * pixelWidth; %% see equation 2.20 in trucco, describing conversion from pixel coord to camera coords
detCenterY = -(rows/2-oy)* pixelHeight;
detCenter = [detCenterX, detCenterY, f]'; 

%%undoing the transformation from the world frame to the camera frame 
%% see page 126, Trucco- we are undoing the extrinisic transformation into
%% the camera frame

%%untranslating from the camera frame into world frame
detCenter = detCenter - T;
%%unrotating from the camere frame into world frame
detCenter = Rinverse*detCenter;

%%original detector orientation values in camera frame
detectorRowDirection = [-1,0,0]'; %%in an unperturbed detector, in camera frame, row direction
detectorColDirection = [0,-1,0]'; %%in an unperturbed detector, in camera frame, col direction
%unrotating the detector orientation to get to world frame
detectorRowDirection = Rinverse*detectorRowDirection; %%no untranslating becuase vectors cant be translated
detectorColDirection = Rinverse*detectorColDirection;

%%Source Calculations
srcCenter = [0, 0, 0]';
%%untranslating
srcCenter = srcCenter - T;
%%Unrotating
srcCenter = Rinverse*(srcCenter);
end

%%returns the transformations required to convert an xray system in a
%%world frame, to one in which sdp1 is along x axis, source0 is where it has been guessed to be,
%%and normal rotation
%%on d1 is 0 (see thesis for the danFrame)
function [RDan, TDan] = ...
    worldToDanFrame(oldExpectedSystem,...
                    srcCenter1,...
                    detCenter1,...
                    detectorRowDirection1,...
                    detectorColDirection1)

%%defining basis1 of the danframe
b1 = detCenter1 - srcCenter1; 
b1 = b1/norm(b1);

%%defining basis3 of the danframe
b3 = cross(detectorRowDirection1, b1);
b3 = b3/norm(b3);

%%defining basis2 of the danframe
b2 = cross(b3, b1);
b2 = b2/norm(b2);

%%the rotation matrix to get to dans frame
RDan = ([b1';b2';b3']);


%%the translation matrix after rotating to get to dans frame

RotatedSRCCenter1 = RDan *srcCenter1; %%rotating the source center to get it on the x axis
expectedSRCCenter1 = xrg_getSourceCenter(oldExpectedSystem,1);

%%getting the translation required to get the sourceCcenter where we expect
%%it to be
TDan = [expectedSRCCenter1(1) - RotatedSRCCenter1(1),...
        expectedSRCCenter1(2) - RotatedSRCCenter1(2),...
        expectedSRCCenter1(3) - RotatedSRCCenter1(3)]';
end




