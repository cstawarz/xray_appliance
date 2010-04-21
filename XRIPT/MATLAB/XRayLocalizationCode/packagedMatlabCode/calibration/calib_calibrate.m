function [calibratedSystem, paramDeltas, simpleDeltas, exitflag, iters] = ...
    calib_calibrate(expectedSystem, calibrationPattern, RHS)

%% calib_calibrate: use this to calibrate the XRAYSystem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	
% [calibratedSystem, paramDeltas, exitflag, iters] = ...
%     calib_calibrate(expectedSystem, calibrationPattern, RHS)
%
% Calibration is the process of finding the system parameters that describe the geometry of the system.
% We need to calibrate because our measurements by eye of the system
% geometry are not 
% good enough to allow accurate reconstruction. This needs to be done before reconstruction. 
%
% Calibration requires a set of extracted feature points form images of the calibration object, 
% as well as knowledge of the geometry of the calibration object.
% The function provided can be used for an XRay system with as many detectors as desired, 
% with whatever detector size desired, provided all detectors are stationary.
%
% Calib_calibrate perturbs the systemDeltas of the expectedSystem guess (see System Guess), 
% and perturbs the calibration object’s position until a simulatedRHS is the same as the input RHS.
% Prior to using the iterative algorithm it generates an improved guess using calib_systemGuess. 
% See Trucco and Verri for details of the linear algorithm used by calib_systemGuess. 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% Input:
% expectedSystem  is a guess at the state of the system that we input to calibration. (see System Guess)
%
% CalibrationPattern is an n*3 array of centerpoints as determined by CT data extraction (see CT Data Extraction). 
%
% RHS is a vector of extracted features from images of the calibration
% object (or a struct with these extracted features, see readme.doc). 
% The order of the extracted features must be the same as the order of the calibration pattern.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output:
%
% calibratedSystem is the expected system after calibration.
%
% systemDeltas is a struct containing data describing the system deltas after calibration
%
% ExitFlag indicates whether calibration converged
% Iters is how many iterations calibration took.
% 
% 
% An example of calibration is in docs_calValDemo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
 

%%calibOutputSimulator variable needs to be global, so that the numerical methods can call
%%the function we are minimizing (calcF) without any parameters other than
%%X. calibOutputSimulator encapsulates any parameters in the
%%function. The calib output simulator calcF method can easily be called
%%from any optimization package
global calibOutputSimulator;

%%debug output
displ = 1;
%%the expectedSystem of the outputSimulator needs to be fully setup before
%%we pass it in. 
xrg_emptySystem(expectedSystem); %emptying prexisting fiducials just in case, and
%%resetting fiducial collection transalation, rotation to 0.
xrg_addFiducials(expectedSystem, calibrationPattern); %%adding our calibratoin pattern


%%checking whether input is nested struct format, struct or vector format. If struct or nested struct,
%convert to vector form
RHS = xrg_RHSVerbose2Vector(RHS);

%% checking values in RHS
%% if the RHS has invalid values for the expectedSystem-
%% negative values, or values large than dimension of one of the arrays, 
%% throw an error. 
if (~Simulator.OutputGenerator.outputInBounds(RHS, expectedSystem))  
    RHS
    size(RHS)
    error('invalid values in RHS.')
end

%%after checking, we form the calibOutputSimulator- this is a java class
%%with a calcF method which we will minimize
calibOutputSimulator = Simulator.CalibStatStatKnown(expectedSystem, RHS);  


%%guess for a solution using linear technique- kind of
 [guess, exitflag] = calib_systemGuess(expectedSystem, calibrationPattern, RHS);


if(displ)
    showIterations = 'iter';
else
    showIterations = 'off';
end

%%numerical method options - levenberg marquardt is used
options = optimset('Display', showIterations, 'LargeScale','off', 'LevenbergMarquardt', 'on',...
'MaxFunEvals', 10000000, 'TolFun', 10^-15, 'TolCon', 10^-15, 'MaxIter', 1000);


fun = @calcF;
[x,resnorm,residual,exitflag,output] = ...
    lsqnonlin(fun,... %%function we are minimizing
    guess,... %%initGuess
    [],... %%lowerBounds
    [],... %%upperBounds
    options); %%convergence criteria, numerical method


if (displ)
    'calibration output'
    output
    display('resnorm')
    norm(residual)
end

calibratedSystem = expectedSystem;
[deltaStruct, simpleDeltas] = xrg_getSystemDeltas(calibratedSystem);
paramDeltas = deltaStruct;
iters = output.iterations;
end


%%the function our numerical method minimizes
function F = calcF(X)
global calibOutputSimulator;
F = calibOutputSimulator.calcF(X); %% see this method in java code for the way system parameters are perturbed
end

