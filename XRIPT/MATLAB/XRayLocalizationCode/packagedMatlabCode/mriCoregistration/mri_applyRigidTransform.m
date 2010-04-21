function [transformedCenters] = mri_applyRigidTransform(rigidTransform, centers)
%% mri_applyRigidTransform: applies a rigid transformation to a set of points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [transformedCenters] = mri_applyRigidTransform(centers, rigidTransform)
% This function applies the transform which is the output of mri_getCoregTransform.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%
% centers: the 3d points we want to transform. n*3 array.
%
% rigidTransform: 6*1 array of transformation parameters. 
%
% rigidTransform(1) = x translation
% rigidTransform(2) = y translation
% rigidTransform(3) = z translation
% rigidTransfrom(4) = x axis rotation in degrees
% rigidTransform(5) = y axis rotation in degrees
% rigidTransform(6) = z axis rotaiton in degrees
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:
% transformedCenters: centers after the transformation described below is applied
% to them, row by row. n*3 array.
%
% Translates centers by rigidTransform(1) in x direction, 
% rigidTransform(2) in y direction, 
% rigidTransform(3) in z direction.
% Rotates translated centers about the z axis by rigidTransform(6) degrees, 
% followed by rotation about y axis by rigidTransform(5) degrees,
% followed by rotation about x axis by rigidTransform(4) degrees.

r1 = mri_rotMat(rigidTransform(4),1);
r2 = mri_rotMat(rigidTransform(5),2);
r3 = mri_rotMat(rigidTransform(6),3);

% r1*r2*r3;
transformedCenters = centers;

transformedCenters(:,1) = transformedCenters(:,1) + rigidTransform(1);
transformedCenters(:,2) = transformedCenters(:,2) + rigidTransform(2);
transformedCenters(:,3) = transformedCenters(:,3) + rigidTransform(3);
         
transformedCenters = r1*r2*r3*transformedCenters';

transformedCenters = transformedCenters';