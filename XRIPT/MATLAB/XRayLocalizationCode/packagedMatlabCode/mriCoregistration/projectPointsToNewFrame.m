function [elementsInNewFrame,err] = projectPointsToNewFrame(elements, ...
                                        sourceFrameName,destinationFrameName) 
% 
% this funciton takes any number of elements and transforms (projects) them 
%  from the source frame (assumed location of the elements) to the named
%  destination frame.

                                        
    % find the transform from the named sourceframe to the named destinationFrame                                
    [FrameTransform, err] = getGlobalFrameTransform(sourceFrameName, destinationFrameName);
    if (err>0) 
        warning(['Transform from frame ' sourceFrameName ' to ' destinationFrameName ' does not yet exist.  Trying to build.']);
        [frameTransform, err] = findRigidTransform('xs','xshg');
        if (err == 0)
            addFrameTransformToGlobalRegistry(frameTransform);      % save it for later use
        else
            error(['Transform from frame ' sourceFrameName ' to ' destinationFrameName ' could not be built.']);
        end
    end
          
    
    % this is a shell around Dan's code to force things into a proper format

    if (length(elements)<1) 
        elementsInNewFrame=[];
        err = 1;
        ['ERROR: applyFrameTransform: no source elements provided.'],
        return;
    end;

    if (~checkRigidTransform(FrameTransform))
        elementsInNewFrame=[];
        err = 1;
        ['ERROR: applyFrameTransform: transform or source elements not as expected.'],
        return; 
    end;


    elementsInNewFrame = elements;
    for k = 1:length(elements);
        loc = elements{k}.location_um;
        elementsInNewFrame{k}.location_um = mri_applyRigidTransform(FrameTransform.parameters,loc);  % dan's code
    end

    err = 0;
    return;

end