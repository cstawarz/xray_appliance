%This function finds the center of the fiducial in image I that is located
%within a bounding box of size 80 x 80 pixels centered at input points
%(xinitial, yinitial).
%Inputs: I = 1024x1000 uint16 image matrix
%(xinitial,yintial) = center point around which the image is cropped.  The fiducial
%in question is assumed to be located somewhere inside the crop region.
%Output:  The center of the fiducial relative to the entire image.  



function [center_x, center_y] = fiducialFinder1(I,xinitial,yinitial, window_size)

%%-------------------------------------------------------------------------
%%Get the bounding box parameters to the image can be cropped around the
%%initial point.

%The crop size here is a default 80 x 80 pixels.  It is not hard-coded
%anywhere else.

MIN_RADIUS = window_size/15;
MAX_RADIUS = window_size/2;

if(MAX_RADIUS > 20)
    MAX_RADIUS = 20;
end

cropSize = window_size;

xmin = xinitial-(cropSize/2);
ymin = yinitial-(cropSize/2);
wid = cropSize;
hgt = cropSize;

if xmin <= 0
    xmin = 1;
end
if ymin <= 0
    ymin = 1;
end

[r1,c1] = size(I);

if (xmin + cropSize) > c1
    xmin = c1 - cropSize;
end
if (ymin + cropSize) > r1
    ymin = r1 - cropSize;
end

%----Crop Image
Isegment = double(imcrop(I,[xmin ymin wid hgt]));
[r,c] = size(Isegment); %For future, when size of cropped image may change

%--------------------------------------------------------------------------

%Filter Vertical Lines
IvertFilt = filtVertLines(Isegment);

%Filter Horizontal Lines
Ifiltered = filtHorLines(IvertFilt);

%--------------------------------------------------------------------------

%Spread image intensity so it occupies 0-255, then normalize values between
%0 -- 1
ImNorm = image_normalization(Ifiltered,255);  
ImNorm = ImNorm/255;

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------

%%Median and wiener filtering:
ImedFilt = medfilt2(ImNorm,[3 3]);
ImedFilt = image_normalization(ImedFilt,1);
IwienFilt = wiener2(ImedFilt,[3 3]);
IwienFilt = image_normalization(IwienFilt,1);


%Wiener filtering sometimes causes artifacts to occurr at the 4 corners of
%the image segment in the form of black pixels.  Their presence will
%negatively impact the image normalization.
%Redefine each corner pixel intensity as the average of its 3 nearest neighbors
IwienFilt(1,1) = (IwienFilt(1,2)+IwienFilt(2,2)+IwienFilt(2,1))/3;
IwienFilt(1,c) = (IwienFilt(1,c-1)+IwienFilt(2,c-1)+IwienFilt(2,c))/3;
IwienFilt(r,1) = (IwienFilt(r-1,1)+IwienFilt(r-1,2)+IwienFilt(r,2))/3;
IwienFilt(r,c) = (IwienFilt(r-1,c)+IwienFilt(r-1,c-1)+IwienFilt(r,c-1))/3;
%Renormalize
IwienFilt = image_normalization(IwienFilt,1);

%-------------------------------------------------------------------------
%Get Seed point from image segment
[spx1,spy1] = getSeedPoint(IwienFilt);

%---------------------------------------------------------------------
%Begin Snakes algorithm
f = 1-IwienFilt; %Invert image
f0 = gaussianBlur(f,1);
f0 = image_normalization(f0,1);

%Get potential of the circle in question
[px,py] = gradient(f0);

% Create a seed contour that is a circle with radius of 3 pixels center
% around the seed point (spx1,spy1)
t = 0:0.5:6.28;   %0--2pi
x1 = spx1 + 3*cos(t);
y1 = spy1 + 3*sin(t);

[x1,y1] = snakeinterp(x1,y1,2,0.5);

%residual = sqrt(sum(differences between data points and best fit
%circle^2))
residual = [];  
circlePoints = {}; %Row cell array to hold the circlePoints for each iteration
radius = [];  %radius = radius of fitted circle
circleCenter = [];  %circleCenter = center of fitted circle
forceRange = [];
circumferences = {};
x = x1;  y = y1;

%%%------------------------------------------------------------------------
%%Apply snakes algorithm for 45x5 iterations for external force parameters
%%in the range EfLow:0.5:15.
%Keep all other parameters constant.  Default values are:
%Elasticity = 0.05;
%Rigidity = 0.1
%Viscosity = 1;
%Pressure force weight = 0.15:  This is the pressure of the contour
%outwards against the gradient edge.  The addition of this parameter helps
%keep the contour more balloon-like, and less deformable.

EfLow = 2;  %Low end of ther external force parameter range
for extForce = EfLow:0.5:15  %Get Snake data for different external force parameter
    try
        %tic
        circumferences{end+1,1} = [];
        for i=1:45        
            [x,y] = snakedeform2(x,y,0.05,0.1,1,extForce,0.15,px,py,5);
            [x,y] = snakeinterp(x,y,2,0.5); 
            %Get circumference of the boundary points
            circumferences{end,1}(end+1) = getCircumference(x,y);
        end
     
        circlePoints{end+1,1}(1,:) = x';
        circlePoints{end,1}(2,:) = y';          
        %Find the best fit circle to the points derived above:
        [circleCenter(end+1,:),radius(end+1),residual(end+1)] = fitcircle(circlePoints{end,1});  
        forceRange(end+1) = extForce;
         
        clear x y
        %Get new values of x and y to start the next series of iterations
        x = x1; y = y1;
        %toc
    catch %If an error has been generated by the snakes, try a new extForce value
        clear x y
        x = x1; y = y1;
%         Discard circumferences for the ext force that produced the
        %error so that the other results all have the same number of
        %elements
        circumferences = circumferences(1:end-1,:);
        continue;
    end
    
end

%Filter data for std of the circumferences of the last 5 iterations of the 
%snake boundaries.  Also filter data for circle radii >=MAX_RADIUS and <= MIN_RADIUS.
%these values are assumed to be in error
circCentKeep = [];
forcesKeep = [];
residueKeep = [];
% radiusKeep = [];

for ii=1:length(circumferences)
    if (length(circumferences{ii,1}) <= 5)
        standardDevsTemp = std(circumferences{ii,1});
    else
        standardDevsTemp = std(circumferences{ii,1}(end-5:end));
    end
     if ((standardDevsTemp < 1) & (radius(ii) < MAX_RADIUS) & (radius(ii) > MIN_RADIUS))
        %standardDevs(end+1) = standardDevsTemp;
        forcesKeep(end+1) = forceRange(ii);
        residueKeep(end+1) = residual(ii);
        circCentKeep(end+1,:) = circleCenter(ii,:);
        %radiusKeep(end+1) = radius(ii);
    end
end


%Get minimum residual value from the valid radii range
%If none of the parameters produced a valid answer, then residueKeep will
%be empty and the program terminates
if ~isempty(residueKeep)
    [minValue,minIndex] = min(residueKeep);
    
    %New start point for second stage of the algorithm, if needed
    spx2 = circCentKeep(minIndex,1);
    spy2 = circCentKeep(minIndex,2);
    dist = sqrt((spx1-spx2)^2 + (spy1-spy2)^2);
    Iterations = 0;
        
    %Rerun snakes for a range of external forces surrounding
    %forceKeep(minIndex).  This will compensate for seed points that were
    %too close to the gradient boundary to produce an optimal result, and
    %a second pass can correct the problem.
    lowerForceIndex = floor(((minIndex-1)/2)) + 1;
    upperForceIndex = floor(((length(forcesKeep)-minIndex)/2))+ minIndex;
    forceRange2 = forcesKeep(1,lowerForceIndex:upperForceIndex);
        
    clear x y
    circlePoints2 = {};
    circleCenter2 = [];
    radius2 = [];
    residual2 = [];
    circumferences2 = {};  
        
    %Only re-apply the algorithm if the distance between the start point
    %and the current best fit circle center is >0.5 pixels, for a maximum
    %of 5 iterations.
    while (dist > 0.5) & (Iterations < 5)
        x2 = spx2 + 3*cos(t); %Seed points are spx and spy computed previously
        y2 = spy2 + 3*sin(t); 
        [x2,y2] = snakeinterp(x2,y2,2,0.5); 
        x = x2;  y = y2;
        for kk=1:length(forceRange2)
                % tic
            try
                circumferences2{end+1,1} = [];
                for i=1:45        
                    [x,y] = snakedeform2(x,y,0.05,0.1,1,forceRange2(kk),0.15,px,py,5);
                    [x,y] = snakeinterp(x,y,2,0.5); 
                    circumferences2{end,1}(end+1) = getCircumference(x,y);
                end
                circlePoints2{end+1,1}(1,:) = x';
                circlePoints2{end,1}(2,:) = y';

                [circleCenter2(end+1,:),radius2(end+1),residual2(end+1)] = fitcircle(circlePoints2{end,1});
                clear x y
                 x = x2; y = y2;
                 % toc
            catch
                clear x y
                x = x2; y = y2;
                circumferences2 = circumferences2(1:end-1,:);
                continue;
            end
        end
        circCentKeep2 = [];
        residueKeep2 = [];
            
        
        %Again, weed out innappropriate solutions
        for nn=1:length(circumferences2)
            if (length(circumferences2{nn,1}) <= 5)
                standardDevsTemp = std(circumferences2{nn,1});
            else
                standardDevsTemp = std(circumferences2{nn,1}(end-5:end));
            end
            if ((standardDevsTemp < 1) & (radius2(nn) < MAX_RADIUS) & (radius2(nn) > MIN_RADIUS))
                residueKeep2(end+1) = residual2(nn);
                circCentKeep2(end+1,:) = circleCenter2(nn,:);

            end
        end
        
        if ~isempty(residueKeep2)
            %Get min residue2 value
            [minValue2,minIndex2] = min(residueKeep2);
            spxTemp = spx2;
            spyTemp = spy2;
            spx2 = circCentKeep2(minIndex2,1);
            spy2 = circCentKeep2(minIndex2,2);   
            %Compute the distance between the new circle center and the
            %previous one to see if another iteration is necessary
            dist = sqrt((spxTemp-spx2)^2 + (spyTemp-spy2)^2);
            Iterations = Iterations+1;
        
        %No new solution fits the criteria, so keep the original circle
        %center break out of the while loop.
        else           
            %Keep the original answer
            spx2 = circCentKeep(minIndex,1);
            spy2 = circCentKeep(minIndex,2);
            break;
        end
    end
    
        %If the second application of snakes reaches the 5th iteration
        %without converging, keep the original circle center that passed all the 
        %criteria prior to the additional iterations
        if (Iterations == 5) & (dist > 0.5)
            cx = circCentKeep(minIndex,1);
            cy = circCentKeep(minIndex,2);
            %Redefine fiducial center in terms of whole image
            center_x = xmin+cx-1;
            center_y = ymin+cy-1;
        else  %No additional iterations were necessary, or the solution converged
            cx = spx2;
            cy = spy2;
            center_x = xmin+cx-1;
            center_y = ymin+cy-1;
        end
else

        %Return an obviously irrational circle center and centerDiff if no fitted circles were
        %found with radii in the specified range (MIN_RADIUS<rad<MAX_RADIUS) and with a std
        %<1 pixel
        center_x = -1;
        center_y = -1;
end
    


