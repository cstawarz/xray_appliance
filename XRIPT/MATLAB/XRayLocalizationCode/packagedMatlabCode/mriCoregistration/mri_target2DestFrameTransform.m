function [points_destFrame, rigidTransform] = target2DestFrameTransform(points_targetFrame, targetFrameCenters, destFrameCenters)
%%target2DestFrameTransform: converts the coordinates of a set of points in one
%%frame to the unknown coordinates in another frame. The transformation to the second frame is specified by
%%providing the known coordinates of the same set of points in both frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This method works by first finding the rigid body transformation to best
% allign targetFrameCenters with destFrameCenters, and then applies this
% transformation to the points whose coordinates we are trying to convert.
% This method assumes that the correspondences between the
% targetFrameCenters and the destFrame centers are correct. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% points_targetFrame: the coordinates of the points in the target frame,
% whose coordinates we don't know in the dest frame. 1*3 array.
%
% targetFrameCenters: the coordinates of a set of points in the target
% referenceFrame. n*3 array.
%
% destFrameCenters: the coordinates of the same set of points that
% have targetFrameCenters as coordinates in the targetFrame, but in the
% destination referenceFrame. n*3 array. The ordering of points must be the
% same in destFrameCenters as in targetFrameCenters.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% point_destFrame: the coordinates of points_targetFrame converted to coordinates in the 
% destination frame.
%
% rigidTransform: the 6*1 array of params that converts points in the
% target frame to points in the dest frame

rigidTransform = mri_getCoregTransform(targetFrameCenters, destFrameCenters);
points_destFrame = mri_applyRigidTransform(rigidTransform, points_targetFrame);
