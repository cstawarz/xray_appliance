function [center] = xrg_getDetectorCenter(expectedSystem, detectorIndex)

%% xrg_getDetectorCenter: gets center of a detector within xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [center] = xrg_getDetectorCenter(expectedSystem, detectorIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% expectedSystem: xraySystem
% detectorIndex: the index of the detector whose center location we want to
% know
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% center:  [x,y,z] describing the center of the detectorIndxth detector in
% the expected system.
%
%
%
    centerj = expectedSystem.getDetectorLocation(detectorIndex - 1); %% -1 because of java indexing
    center(1) = centerj.x;
    center(2) = centerj.y;
    center(3) = centerj.z;
end