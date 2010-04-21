function[centerPoints] = xrg_getFiducialCenters(system)

%% xrg_getFiducialCenters: gets centers of fiducials in system, taking into
%% acount any perturbations from initial positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function[centerPoints] = xrg_getFiducialCenters(system)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Inputs: 
% system: XRAYSystem from which we want to get the positions of fiducial
% centers. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
% centerPoints :
% n*3 array of the present locations of fiducials in system .
% (Taking into account pretubation of the fiducial collection)
%
% The present centerpoints of the fiducials become the rows
% of centerPoints- the first row is the (x,y,z) center of fiducial1, the
% second row is the (x,y,z) center of fiducial2, and so on
%
% The fiducials are ordered according to the order in which they were added
% to the system.

for i = 1:system.getNumberOfFiducials()
    center = system.getFiducialLocation(i-1); %% 0 indexing in java
    centerPoints(i,1) = center.x;
    centerPoints(i,2) = center.y;
    centerPoints(i,3) = center.z;
end