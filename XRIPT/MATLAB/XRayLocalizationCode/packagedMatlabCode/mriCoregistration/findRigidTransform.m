function [FrameTransform, err] = findRigidTransform(sourceFrame,destinationFrame)

%  The element correspondence across frames is determined by the element names (strcmp)

% try to find enough matching elements in each frame
sourceElements = sourceFrame.elements;              % all elements visible in this frame
destinationElements = destinationFrame.elements;    % all elements visible in this frame

clear targetCenters;
clear destCenters;

k = 0;
for i = 1:length(sourceElements);
    sourceElementName = sourceElements{i}.name;
    for j = 1:length(destinationElements);
        destinationElementName = destinationElements{j}.name;
        if (strcmp( sourceElementName,destinationElementName))
            k = k+1;
            targetCenters(k,1:3) = sourceElements{i}.location_um;
            destCenters(k,1:3) = destinationElements{j}.location_um;
        end
    end
end

if (k<3)
    error('findRigidTransform cannot find frame -- not enough matching elements');
    return;
end


%% now build the transform
[rigidTransform, resnorm] = mri_getCoregTransform(targetCenters, destCenters);
%[rigidTransform, resnorm] = mri_getCoregTransform_verJJD1(targetCenters, destCenters);

FrameTransform.sourceFrameName = sourceFrame.name;
FrameTransform.destinationFrameName = destinationFrame.name;
FrameTransform.parameters = rigidTransform';
FrameTransform.resnorm = resnorm;


err = 0;
return;

