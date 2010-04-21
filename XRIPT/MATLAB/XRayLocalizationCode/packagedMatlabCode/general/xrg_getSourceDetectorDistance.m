function [distance] = xrg_getSourceDetectorDistance(expectedSystem, sdpIndex)
%% xrg_getSourceDetectorDistance: get the distance between source and detector in an xray system.
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [center] = xrg_getSourceDetectorDistance(expectedSystem, sourceIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%
% expectedSystem: XRAYSystem we are querying
% sdpIndex: index of the source detectorPair whose focal distance we want
% to know. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:
%
% distance: distance from the center of the sdpIndxth source to the sdpIndxth detector in
% the expected system.
%
%

d = xrg_getDetectorCenter(expectedSystem, sdpIndex);
s = xrg_getSourceCenter(expectedSystem, sdpIndex);
distance = norm(s-d);
end