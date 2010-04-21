function initializeAlexFrames(frameDirectoryName)


% specify the fixed frames that will be used (hopefully for the entire
% experiment)

% random fiducials for testing
loc1 = getRandomLocation;
loc2 = getRandomLocation;
loc3 = getRandomLocation;
loc4 = getRandomLocation;
loc5 = getRandomLocation;


xx = [0 0 0];

%% build each frame and all its elements (this should be a gui)

%% this is the layout of Alex's xray fiducials in the calibrated xray
%%  system coordinates  (only needs to be done once)
frameName = 'xhs_Alex_01';
fullFramefileName = [frameDirectoryName '/' frameName]
[frame] = makeNewFrame(frameName,'xray head stable frame determined Oct 2006');
[frame,err] = addElementToFrame(frame,'alex_f1',loc1,'x');
[frame,err] = addElementToFrame(frame,'alex_f2',loc2,'x');
[frame,err] = addElementToFrame(frame,'alex_f3',loc3,'x');
[frame,err] = addElementToFrame(frame,'alex_f4',loc4,'x');
[frame,err] = addElementToFrame(frame,'alex_f5',loc5,'x');
save(fullFramefileName,'frame');



%% plastic frame
%% these are the coordinates of the fiducials in either
%%  machining units or from microCT
frameName = 'p_Alex_01';
fullFramefileName = [frameDirectoryName '/' frameName]
[frame] = makeNewFrame(frameName,'Alex first plastic frame');
[frame,err] = addElementToFrame(frame,'alex_f1',xx,'x');
[frame,err] = addElementToFrame(frame,'alex_f2',xx,'x');
[frame,err] = addElementToFrame(frame,'alex_f3',xx,'x');
[frame,err] = addElementToFrame(frame,'alex_f4',xx,'x');
[frame,err] = addElementToFrame(frame,'alex_f5',xx,'x');
[frame,err] = addElementToFrame(frame,'alex_m1',xx,'m');
[frame,err] = addElementToFrame(frame,'alex_m2',xx,'m');
[frame,err] = addElementToFrame(frame,'alex_m3',xx,'m');
[frame,err] = addElementToFrame(frame,'alex_m4',xx,'m');
save(fullFramefileName,'frame');


%% this is the current anatomical MR frame
frameName = 'm_Alex_01';
fullFramefileName = [frameDirectoryName '/' frameName]
[frame] = makeNewFrame(frameName,'Alex first anatomical mri frame');
[frame] = addElementToFrame(frame,'alex_m1',xx,'m');
[frame] = addElementToFrame(frame,'alex_m2',xx,'m');
[frame] = addElementToFrame(frame,'alex_m3',xx,'m');
[frame] = addElementToFrame(frame,'alex_m4',xx,'m');
save(fullFramefileName,'frame');


end


% =========================================================================
function [loc] = getRandomLocation() 
    loc = (rand(1,3)*5000) + 10000;
    return;
end