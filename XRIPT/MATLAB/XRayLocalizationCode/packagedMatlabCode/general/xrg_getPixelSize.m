function [heightWidth] = xrg_getPixelSize(expectedSystem, detectorIndex)

%% xrg_getPixelSize: gets number of rows, columns in detector in xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [rowscols] = xrg_getPixelSize(expectedSystem, detectorIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% inputs:
%
% expectedSystem: XRaySystem we are querying
%
% detectorIndex: the index of the detector we are querying
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% outputs: 
% 
% heightWidth: [height of pixel in detectorIndxth detector, width of pixel in detectorIndxth detector]
%
%
    heightWidth(1) = expectedSystem.getSDP(detectorIndex-1).getDetector().getPixelHeight();
    heightWidth(2) = expectedSystem.getSDP(detectorIndex-1).getDetector().getPixelWidth();
end