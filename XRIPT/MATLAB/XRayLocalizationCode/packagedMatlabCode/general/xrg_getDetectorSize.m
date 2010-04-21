function [rowscols] = xrg_getDetectorSize(expectedSystem, detectorIndex)

%% xrg_getDetectorSize: gets number of rows, columns in detector in xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [rowscols] = xrg_getDetectorSize(expectedSystem, detectorIndex)
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
% rowscols: [rows in the detectorIndxth detector, cols in the detectorIndxth detector
%
%
    rowscols(1) = expectedSystem.getSDP(detectorIndex-1).getDetector().getRows();
    rowscols(2) = expectedSystem.getSDP(detectorIndex-1).getDetector().getColumns();
end