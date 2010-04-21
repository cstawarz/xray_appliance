function [frame,err] = addElementToFrame(frame,element_name,location_um,visibility)

% this function adds an element (e.g. a fiducial) the list of known
% elements contained within a frame.  The location is [x y z] and is
% assumed to be (by definition) in the coordinates of the indicated frame.
%  JJD Oct 2006

    replace = 0;
    if (isfield(frame,'elements'))    
        nElements = length(frame.elements);
    else
        nElements = 0;
    end
    
    % check element name not already used -- if so, replace it.
    err = 0;
    for k = 1:nElements
        if (strcmp(element_name,frame.elements{k}.name))
            replaceElementNumber = k;
            replace = 1;
        end
    end
   
    %% check visibility is properly fomatted    
    if   ( strcmp(visibility,'x')  | strcmp(visibility,'xm') | ...
            strcmp(visibility,'m') | strcmp(visibility,'mx') )
        [' '];    
    else
        error('ERROR:  visibility not properly formatted.  expect: x m xm or mx');
        err = 1,
        return;
    end

    
    
    clear element;
    element.name = element_name;
    element.location_um = location_um;
    element.visibility = visibility;
    
    if (replace)
        warning('Replacing older element in frame with new element provided.');
        frame.elements{replaceElementNumber} = element;
    else
        frame.elements{nElements+1} = element;
    end

    err = 0;
    return;
end