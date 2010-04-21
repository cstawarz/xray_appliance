function [transformPackage, err_string] = runCoregistration(xrayPackageName, Frame)

transformPackage = [];
err_string = '';

%  JJD Oct, 2006
%  This function leverages all the shell code that JJD wrote for
%  streamlining and error control
%
%  This should be made into a GUI.
%
%  It does the following:
%   1) looks for properly-formatted data in the xrayPackage (3D location of
%  fiducials and names)
%
%   2) tries to find all frame files needed for transform (xsh, p, m)
%       (this may change in the future, but easy to change here)
%     (The GUI version would allow selection of each of these frame files from the
%     directory)
%
%   3) computes the transforms between the named frames
%
%   4) projects all the data from teh xrayPackage into all frames
%
%   5) saves this projected data in the xrayPackage in the "coregistration"
%   folder, along with the frame data and transforms used to project.
%
%  It should be able to run in unserpervised mode (e.g. batch).
%
%
%  THIS ROUTINE REQUIRES that one first create properly formatted frame
%  data in the indicated frameDirectoryName
%   For now, the required frames can be created by running the function:
%   initializeAlexFrames(frameDirectioryName)
%
%  It is in this function that the locations of fiducials in the various
%  frames are indicated.
%
%   but this should be part of a gui in the future (choose among a
%   directory of avialable frames)


% =================================================
%  1) look for properly-formatted data in the xrayPackage (3D location of
%  fiducials and names)

%% spec needed here
%try
    % convert to JJD style frame:
    xsFrame = convertBundleToFrame(xrayPackageName);
    
    
%catch
 %   err_string = 'xray package data could not be loaded.';
 %   fprintf(2, '%s\n', err_string);
    
%    return;
%end


fprintf(2, '%s\n', ['Successfully loaded xs frame data named:  ' xsFrame.name]);

if (length(xsFrame.elements)<3)
    err_string = 'Not enough elements (<3) in the loaded xs data for coregistration.';
    fprintf(2, '%s\n', err_string);
    return;
end





%% =================================================
%   2) try to find all frames needed for transform (xsh, p, m)
%       (this may change in the future, but easy to change here)

Frame = {xsFrame Frame{1,:}}





%% =================================================
for i= 1:(length(Frame)-1)
    [frameTransform, err] = findRigidTransform(Frame{i}, Frame{i+1})
    if (err == 0) 
        addFrameTransformToGlobalRegistry(frameTransform); 
        allTransforms{i} = frameTransform;  % for later saving
        fprintf(2, 'Finding xform between %s and %s\n', Frame{i}.name, Frame{i+1}.name);
    else
        err_string = ['Transform between frame ' Frame{i}.name ' and frame '  Frame{i+1}.name ' was not solved.'];
        fprintf(2, '%s\n', err_string);
        return;
    end
    clear frameTransform;
end

%% now all required transforms are built and registered
fprintf(2, 'now all required transforms are built and registered\n');



%% =================================================
%   4) project all the data from the xrayPackage (xsFrame) into all the other frames
%

dataElementsInAllFrames{1}.elements = xsFrame.elements;
dataElementsInAllFrames{1}.frameName = xsFrame.name;

for i= 1:(length(Frame)-1)
    
    [projectedElements,err] = projectPointsToNewFrame(dataElementsInAllFrames{i}.elements, Frame{i}.name, Frame{i+1}.name);
    
    if (err == 0) 
        dataElementsInAllFrames{i+1}.elements = projectedElements;
        dataElementsInAllFrames{i+1}.frameName = Frame{i+1}.name;
    else
        err_string = ['Projection from frame ' Frame{i}.name ' to frame '  Frame{i+1}.name ' failed.'];
        fprintf(2, '%s\n', err_string);
        return;
    end
end


%% =================================================
%   5) save this projected data in the xrayPackage in the "coregistration"
%   folder, along with the frame data and transforms used to project.

clear CoregData;

CoregData.Frame = Frame;                               %% all frames
CoregData.Transform = allTransforms;                             %% all transforms that were used
CoregData.dataElementsInAllFrames = dataElementsInAllFrames;     %% data points from xray package projected through all frames

transformPackage = CoregData;

fullMatlabName = [xrayPackageName '/3D_reconstruction/matlabCoregData']
save(fullMatlabName,'CoregData');

for ii=2:length(dataElementsInAllFrames)
    recon_filename = [xrayPackageName '/3D_reconstruction/recon_' dataElementsInAllFrames{ii}.frameName];
    recon_centers = dataElementsInAllFrames{ii};
    
    save(recon_filename, 'recon_centers');
end


return;






