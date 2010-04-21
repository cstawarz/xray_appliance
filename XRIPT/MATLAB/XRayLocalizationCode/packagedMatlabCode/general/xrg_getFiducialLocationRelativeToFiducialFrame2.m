function [location] = xrg_getFiducialLocationRelativeToFiducialFrame2(...
    targetCoordinate, f1Coordinate, f2Coordinate, f3Coordinate)

%% xrg_getFiducialLocationRelativeToFiducialFrame2: localizes target with respect to centers 1,2,3
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [location] = xrg_getFiducialLocationRelativeToFiducialFrame2(...
%     targetCoordinate, f1Coordinate, f2Coordinate, f3Coordinate)
%
% Given a set of 4 center points, localizes the targetCoordinate with respect to other 3
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
% TargetCoordinate: is the location of the target center point that we want
% to localize. [x,y,z] array.
%
% f1Coordinate: center of the jth fiducial. [x,y,z] array.
%
% f2Coordinate: center of the kth fiducial. [x,y,z] array.
%
% f3Coordinate: center of the lth fiducial. [x,y,z] array.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output:
% Location: The localization of targetCoordinate with respect to frame formed by fiducials at f1Coordinate, f2Coordinate, f3Coordinate. 3*1 array


    
    targetJ = javax.vecmath.Point3d(targetCoordinate(1), targetCoordinate(2), targetCoordinate(3));
    f1J = javax.vecmath.Point3d(f1Coordinate(1), f1Coordinate(2), f1Coordinate(3));
    f2J = javax.vecmath.Point3d(f2Coordinate(1), f2Coordinate(2), f2Coordinate(3));
    f3J = javax.vecmath.Point3d(f3Coordinate(1), f3Coordinate(2), f3Coordinate(3));
    locj = Simulator.XRAYSystem.getFiducialLocationRelativeToFiducialFrame(targetJ, f1J, f2J, f3J);
    location = [locj.x,locj.y,locj.z]; %%converting back frrm java
end