function [frameTransform,err] = getGlobalFrameTransform(sourceFrameName,destinationFrameName);

% return the frame transform from the registry that can be used to go from the source frame
% to the destination frame
% 
    global globalFrameTransforms;
    
    for k = 1:length(globalFrameTransforms);    
        if ( strcmp(sourceFrameName,globalFrameTransforms{k}.sourceFrameName) & ...
                strcmp(destinationFrameName,globalFrameTransforms{k}.destinationFrameName) ) 
            frameTransform = globalFrameTransforms{k}; 
            err = 0;
            return;
        end
    end

    frameTransform = [];
    err = 1;
    return;
    
end