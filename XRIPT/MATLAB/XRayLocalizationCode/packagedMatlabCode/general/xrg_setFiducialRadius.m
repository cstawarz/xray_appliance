function [] = xrg_setFiducialRadius(system, radius)

%% xrg_setFiducialRadius: change the radius of fiducals in the system
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% function [] = xrg_setFiducialRadius(system,radius)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% system: XRaySystem whose fiducials we want to modify 
% modifies system.
%
% radius: double that we set the radius of all fiducials to be. It is
% assumed that fiducials are spheres. 
%
%%%%%%%%%%%%%%%%%%
% Modifies:
%
% system. sets the radius of all fiducials in the system to be radius (microns)
%
%%%%%%%
% Call this before calling slowProject, or all fiducials will have radius
% 0

for i=1:system.getNumberOfFiducials()
   system.setLightFiducialRadius(radius,i-1); %%i-1 for java indedxing
end

