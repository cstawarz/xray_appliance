function [rigidTransform, correctedDestCenters, resnorm] = mri_getCoregTransformAdvanced(targetCenters, destCenters)
% mri_matchIgnoreCorrespondences: coregisters unordered, as well as extra centers
%%%%%%%%%%%%%%%
%
% [rigidTransform, correctedDestCenters, resnorm] = mri_getCoregTransformAdvanced(targetCenters, destCenters)
%
% This function is similar to mri_getCoregTransform, except it no longer
% assumes that the correspondence implicit in the ordering of targetCenters
% and destCenters is correct, and also does not assume that all destCenters
% points are correct; i.e destCenters could be in the wrong order, and
% contain superfluous points. 
%
% This function finds the best rigid body transform, 
% as well as the best permuted Subset of destCenters 
% such that if the transform is applied to targetCenters, 
% the transformed targetCenters will most closely (by least squares metric)
% match the permuted subset of destCenters.
%
% In effect it minimizes over two variables at once: the
% correct version of destCenters as well as
% the coregistraion transform for that correct version. 
% It attempts coregistration exhaustively;
% mri_getCoregTransform is called for every permuted Subset.
% 
% The permuted subset of destCenters and associated
% transform that minimizes the coregistration residual are the returned values
% 
% One way to use this function, would be to find the transform from rigid xrayData (targetCenters) 
% to unordered rigid mriData (destCenters) containing the same set of
% points, along with extra points. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs: 
%
% targetCenters: the coordinates of centerpoints in one frame,
% which  we want to coregister to the coordinates of the same centerpoints  in
% another frame (destCenters). n*3 array. If we are coregistering rigid xrayData to mri data,
% rigid xrayData should be targetCenters. 
%
% destCenters: the coordinates of the targetCenters, but in a different reference
% frame. m*3 array. destCenters need not be in the same order as targetCenters, 
% and can contain superfluous points. If we are coregistering rigid xrayData to mri data,
% mriData should be destCenters. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Outputs:
%
% rigidTransform = 6*1 vector containing translation and rotation elements of the
% coregistration transformation (from targetCenters to correctedDestCenters)  
%
% If the rigidTransform were applied to targetCenters, it would
% translate targetCenters by rigidTransform(1) in x direction, 
% followed by translation by rigidTransform(2) in y direction,
% followed by translation by rigidTransform(3) in z direction.
% It would then rotate the translated targetCenters about the z axis by rigidTransform(6),
% Followed by rotation about y axis by rigidTransform(5),
% Followed by rotation about z axis by rigidTransform(4).
%
% correctedDestCenters:
% n*3 array of the permuted subset of destCenters to which targetCenters
% can be most closely coregistered. 
%
% resnorm = least squares measure of how well the transformed 
% targetCenters match corectedDestCenters
% (norm(rigidTransform*targetCenters - correctedDestCenters))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires:
% size(destCenters)>= size(targetCenters)
%
%

if (size(targetCenters,2)~=3||...
        (size(destCenters,2)~=3)||...
        (size(targetCenters,1)>size(destCenters,1)))
    error('malformatted inputs- check their dimensions') 
end

% minResnorm = 1000000000000;
% more = 0;
% k = size(targetCenters,1);
% n = size(destCenters,1);
% A = [];
% 
% %%forming subsets and trying them out in mri_matchIgnoreCorrespondences
% first = 1;
% while ((more == 1)||(first==1))
%     first = 0; 
%     
%     [A,more] = ksub_next(n,k,A,more);
% %     centers1
%     subsetA = destCenters(A,:);
%     
% [rigidTransform, correctedDestCenters, resnorm] = ...
%     mri_reorder(targetCenters, destCenters);
%     
%     if (residuala<resnorm)
%         minRigidTransform = rigidTransform;
%         minCorrectedDestCenters = correctedDestCenters
%         minResnorm = resnorm
%     end 
% end



[rigidTransform, correctedDestCenters, resnorm] = ...
    mri_reorder(targetCenters, destCenters);

end


%%internal function used to check all permutations of a given set of destCenters
%%destCentersMin is a permutaiton of the destCenters passed in
%requires destCenters and targetCenters have the same size
function [rigidTransformMin, destCentersMin, resnormMin] = ...
    mri_reorder(targetCenters, destCenters)

if ((size(targetCenters,1)~=size(destCenters,1))||...
        (size(targetCenters,2)~=size(destCenters,2)))
    error('bad input into mri_reorder');
end

numPoints = size(targetCenters,1);
sequence = [1:1:numPoints];
allPerms = perms(sequence);

resnormMin = 1000000000000;

%%trying out every permutation of destCenters
for i=1:size(allPerms,1)
    permutation = allPerms(i,:);
    
    %%accumulating a particular permutation of destcenters
    permutedDestCenters = [];
    for j = 1:length(permutation) 
        destCentersIndex = permutation(j);
        permutedDestCenters(j,:) = destCenters(destCentersIndex,:);
        % the jth element of the corrected destCenters
        % will be the the destCentersIndex element of destCenters 
    end
    
    [rigidTransform, resnorm] = mri_getCoregTransform(targetCenters, permutedDestCenters);
    if (resnorm<=resnormMin)
        rigidTransformMin = rigidTransform;
        resnormMin = resnorm;
        destCentersMin = permutedDestCenters;
    end 
end
end



