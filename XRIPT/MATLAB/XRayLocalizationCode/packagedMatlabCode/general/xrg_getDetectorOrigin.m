function [origin] = xrg_getDetectorOrigin(expectedSystem, detectorIndex)

%% xrg_getDetectorOrigin: gets top left of top left pixel of a detector in xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [origin] = xrg_getDetectorCenter(expectedSystem, detectorIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% expectedSystem: xraySystem
% detectorIndex: the index of the detector whose origin (top left of top left pixel) location we want to
% know
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% origin:  [x,y,z] describing the origin of the detectorIndxth detector in
% the expected system.
%
%
    originj = expectedSystem.getSDP(detectorIndex - 1).getDetector().getOrigin(); %% -1 because of java indexing
    origin(1) = originj.x;
    origin(2) = originj.y;
    origin(3) = originj.z;
end