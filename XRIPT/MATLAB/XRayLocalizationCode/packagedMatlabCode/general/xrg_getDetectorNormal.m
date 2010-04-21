function [normal] = xrg_getDetectorNormal(expectedSystem, detectorIndex)

%% xrg_getDetectorNormal: gets normal vector of a detector within xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [normal] = xrg_getDetectorNormal(expectedSystem, detectorIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% expectedSystem: xraySystem
% detectorIndex: the index of the detector whose normal vector we want to
% know
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% normal:  [x,y,z] describing thenormal vector of the detectorIndxth detector in
% the expected system.
%
%
    normalj = expectedSystem.getSDP(detectorIndex-1).getDetector().getNormal; %% -1 because of java indexing
    normal(1) = normalj.x;
    normal(2) = normalj.y;
    normal(3) = normalj.z;
end