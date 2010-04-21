function[] = xrg_addFiducials(system, centerPoints)

%% xrg_addFiducials: use to add fiducials at specific points to an xray system
%%
%%%%%%%%%%%%%%
%
% [] = xrg_addFiducials(system, centerPoints)
%
% adds fiducials to xray system at centerpoints 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% system: an XRAYSystem
%
% centerPoints: n*3 array dexcribing the centers of the fiducials that we
% want to add to the system, where the first row is the 
% (x,y,z) center of fiducial1, the
% second row is the (x,y,z) center of fiducial2, and so on. 
%
% Alternately, if centerpoints is a scalar, then centerPoints fiducials will be added to XRaySystem at (0,0,0) 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs: none
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modifies:
%
% system gains fiducials, either at the locations specified by centerPoints
% or in the number specified by centerPoints (all at the origin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: calling xrg_getFiducialCenters later on returns the updated position of the
% fiducials, not where they were added to- for example,
% if a fiducial is added at (1,0,0) to a system whose fiducial collection had been
% PREVIOUSLY rotated 90 degrees clockwise (using setSystemDeltas), calling getFiducials right
% after this will return a center point at (0,1,0)

if size(centerPoints) == [1,1];
    xrg_addFiducials1(system, centerPoints);
else

for i = 1:size(centerPoints,1)
    centerx = centerPoints(i,1);
    centery = centerPoints(i,2);
    centerz = centerPoints(i,3);
    system.addDefaultLightFiducial(centerx, centery, centerz)
end
end