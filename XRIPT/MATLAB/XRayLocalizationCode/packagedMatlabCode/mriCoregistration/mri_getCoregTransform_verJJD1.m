function [rigidTransform, resnorm] = mri_getCoregTransform_verJJD1(targetCenters, destCenters)

%%  mri_getCoregTransform: function that solves for coregistration transform between rigid, ordered sets of centers
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [rigidTransform, resnorm] = mri_getCoregTransform(targetCenters, destCenters)
% 
% This function finds the best rigid body transform, 
% such that if the transform is applied to targetCenters, 
% (without reordering destCenters or targetCenters) 
% the transformed targetCenters will most closely (by least squares metric)
% match destCenters, over all rigid transforms.
% 
% One way to use this function, would be to find the transform from ordered rigid xrayData (targetCenters) 
% to ordered rigid mriData (destCenters) of the same set of points.
%
% That is, if the implicit correspondences between the ordering of the rigid xray data,
% and the ordering of the rigid mri data are correct, and there is no superfluous mri data, 
% use this function. If the corrspondences are incorrect, this function
% will fail to converge to a good answer.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs: 
%
% targetCenters: the coordinates of centerpoints in one frame,
% which  we want to coregister to the coordinates of the same centerpoints  in
% another frame (destCenters). n*3 array. 
% targetCenters should be in the same order as destCenters. 
% If we are coregistering rigid xrayData to mri data,
% rigid xrayData should be targetCenters. 
%
% destCenters: the coordinates of the targetCenters, but in a different reference
% frame. n*3 array. targetCenters should be in the same order as destCenters. 
% If we are coregistering rigid xrayData to mri data,
% mriData should be destCenters. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Outputs:
%
% rigidTransform = 6*1 vector containing translation and rotation elements of the
% coregistration transformation (from targetCenters to destCenters)  
%
% If the rigidTransform were applied to targetCenters, it would
% translate targetCenters by rigidTransform(1) in x direction, 
% followed by translation by rigidTransform(2) in y direction,
% followed by translation by rigidTransform(3) in z direction.
% It would then rotate the translated targetCenters about the z axis by rigidTransform(6),
% Followed by rotation about y axis by rigidTransform(5),
% Followed by rotation about z axis by rigidTransform(4).
%
% resnorm = least squares measure of how well the transformed targetCenters
% match destCenter:
% (norm(rigidTransform*targetCenters - destCenters))

if (size(targetCenters,2)~=3||...
        (size(destCenters,2)~=3)||...
        (size(targetCenters,1)~=size(destCenters,1)))
    targetSize = size(targetCenters)
    destSize = size(destCenters)
    error('malformatted inputs- check their dimensions') 
end
    
displ = 0 ;

if(displ)
    showIterations = 'iter';
else
    showIterations = 'off';
end

options = optimset('Display',showIterations,'LargeScale','off', 'LevenbergMarquardt', 'on', 'MaxFunEvals', 1000000,... %%1000000 functional evaluations
    'TolFun', 10^-15, 'TolCon', 10^-15, 'MaxIter', 3000); %%10000 iterations marigidTransform

centerMassDiff = mean(destCenters) - mean(targetCenters);
dx = destCenters(1,1) - targetCenters(1,1);
dy = destCenters(1,2) - targetCenters(1,2);
dz = destCenters(1,3) - targetCenters(1,3);

%guess = [centerMassDiff(1);centerMassDiff(2);centerMassDiff(3);0;0;0]; 
guess = [dx;dy;dz;0;0;0]; 

[rigidTransform,resnorm,residual,exitflag,output] = ...
    lsqnonlin(@(rigidTransform) mri_calcF(rigidTransform, targetCenters, destCenters),... %%function we are minimizing
    guess,... %%initGuess
    [],...
    [],...
    options); %%convergence criteria, numerical options
end


function [F] = mri_calcF(x, centers1, centers2)
%% mri_calcF: function that is minimized when we are doing coregistraton
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mri_calcF(x, centers1, centers2)
%
% given a vector x of translation and rotation parameters, translates and
% rotates centers1, and then subtracts centers2 and returns. Meant to be
% used in iterative center matching algorithm. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs:
% x: 6*1 array of transformation paramters
% x(1): xtranslation
% x(2): ytranslation
% x(3): ztranslation
% x(4): xaxis rotation in radians
% x(5): yaxis rotation in radians
% x(6): zaxis rotation in radians
%
% centers1: n*3 array of points
%
% centers2: n*3 array of points
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output:
% F: The result of the following operation
%
% Translates centers1 by x(1) in x direction, x(2) in y direction, x(3) in
% z direction.
%
% Rotates translated centers1 about the z axis by x(6), 
% followed by rotation about y axis by x(5),
% followed by rotation about x axis by x(4).
%
% Subtracts centers2 from translated and rotated centers1 
%
%

newCenters = mri_applyRigidTransform(x, centers1);
F = centers2-newCenters;

end
