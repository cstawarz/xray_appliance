function [bool] = checkRigidTransform(FrameTransform)

%% basic check of transform format

    bool = 0;
    [m,n] = size(FrameTransform.parameters);
    if ((m ~=1) | (n ~=6))
        error('transform parameters not in expected 1x6 format.');
        return; 
    end;
    bool = 1;
    return;

end