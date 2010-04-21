function addFrameToGlobalRegistry(frame);

    global globalFrames;

    nf = length(globalFrames);
    
    % if name of frame already exist, then replace it   
    replace = 0;
    for k = 1:nf
        if (strcmp(frame.name,globalFrames{k}.name))
            replaceElementNumber = k;
            replace = 1;
            warning('Replacing frame with one of the same name.');
        end
    end
    
    if (replace)
        globalFrames{replaceElementNumber} = frame;
    else
        globalFrames{nf+1} = frame;
    end
    
end