function addFrameTransformToGlobalRegistry(frameTransform)
    
% use this function to add a computed transform to the registry of known
% transforms

   global globalFrameTransforms;
    
   nf = length(globalFrameTransforms);
    
    % if this frame transform already exists in the registry, then replace it   
    replace = 0;
    for k = 1:nf
        if ( strcmp(frameTransform.sourceFrameName,globalFrameTransforms{k}.sourceFrameName) & ...
             strcmp(frameTransform.destinationFrameName,globalFrameTransforms{k}.destinationFrameName) ) 
            replaceElementNumber = k;
            replace = 1;
            warning('Frame transform already exists.  Replacing.');
        end
    end

    if (replace)
        globalFrameTransforms{replaceElementNumber} = frameTransform;
    else
        globalFrameTransforms{nf+1} = frameTransform;
    end 
   
end

