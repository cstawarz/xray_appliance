function [location] = xrg_getFiducialLocationRelativeToFiducialFrame(expectedSystem, target, f1, f2, f3)

%% xrg_getFiducialLocationRelativeToFiducialFrame2: localizes target with respect to centers f1,f2,f3
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [location] = xrg_getFiducialLocationRelativeToFiducialFrame2(...
%     target, f1, f2, f3)
%
% Given a set of 4 fiducial indexes, localizes the target indxth fiducial
% with respect to f1th, f2th, f3th fiducials
%
% A refererence frame is formed out of fiducials j,k,l, by:
% 
% ¥ jth fiducial as origin, 
% ¥ Basis1 is normalized vector from jth fiducial to  kth fiducial.
% ¥ Basis2 is normalized part of the vector from jth fiducial to lth fiducial that is perpendicular to basis1. 
% ¥ Basis3 is cross product of basis1 and basis2
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% Inputs:
%
% expectedSystem: the XRay system containing the reference frame fiducials and target
%
% Target: the index of the target fiducial point that we want
% to localize. 
%
% f1: the index of the jth fiducial used to generate a frame. 
%
% f2: the index of the kth fiducial used to generate a frame. 
%
% f3: the index of the lth fiducial used to generate a frame. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output:
%
% Location: The localization of targetth fiducial with respect to frame
% formed by the f1th fiducial, f2th fiducial, f3th fiducial. 3*1 array
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requires:
% target, f1th, f2th, f3th fiducials exist in the xray system
%

    locationj = expectedSystem.getFiducialLocationRelativeToFiducialFrame(target-1, f1-1, f2-1, f3-1);
    location(1) = locationj.x;
    location(2) = locationj.y;
    location(3) = locationj.z;
end