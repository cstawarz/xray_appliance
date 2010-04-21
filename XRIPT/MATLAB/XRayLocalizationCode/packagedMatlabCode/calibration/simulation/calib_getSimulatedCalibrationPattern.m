%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% calib_getSimulatedCalibrationPattern
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% function [calibrationPattern] = calib_getSimulatedCalibrationPattern()
%% 
%% returns a calibration pattern of fiducials simulating an ideal calibration
%% object. 
%%

function [calibrationPattern] = calib_getSimulatedCalibrationPattern()

count = 1;
spacing = 1200;

displ = 0;
if(displ)
    'using calibration object'
end

fc = Simulator.FiducialCollection.BuildDefault();
fidsInRow = 4;
% spacing = 1500/1.4;
xVector = [1,0,0]';
yVector = [0,1,0]';
zVector = [0,0,1]';

thetaZ = deg2rad(12);
tform1 = [cos(thetaZ), -sin(thetaZ), 0;...
          sin(thetaZ), cos(thetaZ),0;...
          0,             0,        1];
          
v1 = tform1*xVector;
v2 = tform1*zVector;

init = [-5000,0,-5000]';
for i = 0:fidsInRow-1
    for j = 0:fidsInRow-1
        position = init + i*spacing*v1 + j*spacing*v2;
        calibrationPattern(count,:) = position;
        count = count + 1;
    end
end
% spacing = 1500/1;
% fc
% fc.getParent()
thetaZ = deg2rad(-12); 
%%thetaX = deg2rad
tform1 = [cos(thetaZ), -sin(thetaZ), 0;...
          sin(thetaZ), cos(thetaZ),0;...
          0,             0,        1];
      
v1 = tform1*xVector;
v2 = -zVector;
init = position + 3000* xVector + 0*yVector;
for i = 0:fidsInRow-1
    for j = 0:fidsInRow-1
        position = init + i*spacing*v1 +j*spacing*v2;
        calibrationPattern(count,:) = position;
        count = count + 1;
    end
end

% spacing = 1500/1;
thetaY = deg2rad(0);
tform2 = [cos(thetaY),     0,        sin(thetaY);...
          0,               1,             0;...
         -sin(thetaY),     0,      cos(thetaY)];

v1 = -tform2*yVector;
v2 =  tform2*zVector;
init = [-2500,000,0]';

for i = 0:fidsInRow-1
    for j = 0:fidsInRow - 1
        position = init + i*spacing*v1 + j*spacing*v2;
        calibrationPattern(count,:) = position;
        count = count + 1;
    end
end

% thetaY = deg2rad(45);
% tform2 = [cos(thetaY),     0,        sin(thetaY);...
%           0,               1,             0;...
%          -sin(thetaY),     0,      cos(thetaY)];
%      
% init = [2500,000,0]';
% v1 = -tform2*yVector;
% v2 =  tform2*zVector;
% 
% for i = 0:fidsInRow-1
%     for j = 0:fidsInRow - 1
%         position = init + i*spacing*v1 + j*spacing*v2;
%         if(displ)
%             fc.addDefaultLightFiducial(position(1), position(2), position(3), radius);
%             %%fc.setRadius(150);
%         else
%             fc.addDefaultLightFiducial(position(1), position(2), position(3));
%         end
%     end
% end


% thetaZ = deg2rad(-12);
% tform1 = [cos(thetaZ), -sin(thetaZ), 0;...
%           sin(thetaZ), cos(thetaZ),0;...
%           0,             0,        1];
%           
% v1 = tform1*xVector;
% v2 = tform1*zVector;
% 
% 
% %%fc = Simulator.FiducialCollection.BuildDefault();
% init = [-5000,0,0]';
% for i = 0:fidsInRow-1
%     for j = 0:fidsInRow-1
%         position = init + i*spacing*v1 + j*spacing*v2;
%         if(displ)
%             fc.addDefaultLightFiducial(position(1), position(2), position(3), radius);
%             %%fc.setRadius(150);
%         else
%             fc.addDefaultLightFiducial(position(1), position(2), position(3)); 
%         end
%     end 
% end
% 
% thetaZ = deg2rad(12); 
% %%thetaX = deg2rad
% tform1 = [cos(thetaZ), -sin(thetaZ), 0;...
%           sin(thetaZ), cos(thetaZ),0;...
%           0,             0,        1];
%       
% v1 = tform1*xVector;
% v2 = -zVector;
% init = position + 3000* xVector + 0*yVector;
% for i = 0:fidsInRow-1
%     for j = 0:fidsInRow-1
%         position = init + i*spacing*v1 +j*spacing*v2;
%         if(displ)
%             fc.addDefaultLightFiducial(position(1), position(2), position(3), radius);
%             %%fc.setRadius(150);
%         else
%             fc.addDefaultLightFiducial(position(1), position(2), position(3));
%         end
%     end
% end

