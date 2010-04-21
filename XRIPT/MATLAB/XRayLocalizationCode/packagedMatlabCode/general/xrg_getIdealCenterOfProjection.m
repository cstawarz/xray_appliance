function [col, row] = xrg_getIdealCenterOfProjection(system, fiducialIndex, detectorIndex)

%% xrg_getIdealCenterOfProjection: get the detector coordinates of the projection of a fiducial onto a detector in the xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [col, row] = 
% xrg_getIdealCenterOfProjection(system, fiducialIndex, detectorIndex)
%
% Given an XRAYSystem, finds the center of projection of the
% fiducialIndxth fiducial, on the detectorIndxth detector, in detector
% coordinates. Works for n detector system. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
% 
% system: xray system the creates simulated
%
% fiducialIndex: the index of the fiducial whose projection we are
% interested in querying. 
%
% detectorIndex: the index of the detector whose projection we are
% quesrying.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs: 
%
% col = pixel column of the detector array, 
% row = pixel row of the detector array. 
%
% The returned values are zero indexed coordinates- careful!


%% - 1 becauase java methods use 0 indexing rather than 1
centers = system.getIdealCentersOfProjection();
 
oneDetector = length(centers)/system.getNumberOfSDP();

 col = centers(oneDetector*(detectorIndex-1) + 2*(fiducialIndex-1) + 1,1);
 row = centers(oneDetector*(detectorIndex-1) + 2*(fiducialIndex-1) + 2,1); 
    
end
 