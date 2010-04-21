function [M] = mri_rotMat(alpha, axis)

%% mri_rotMat: Used to form rotation matrices.
% 
% alpha is in degrees. Axis is index of, x,y, or z axis.
% returns rotation matrix of rotating alpha degrees counterclockwise about 1 (x axis), 2, (y
% axis) or 3 (z axis) 

alphaPrime = - deg2rad(alpha); %%- to go counterclockwise

s = sin(alphaPrime);
c = cos(alphaPrime);
if (axis == 1)

    M = [1, 0, 0;
        0,  c, s;
        0, -s, c];

elseif (axis == 2)
    
    M = [c, 0, -s;
        0, 1, 0;
        s, 0, c];

elseif (axis == 3)

    M = [c, s, 0;
        -s, c, 0;
        0, 0, 1];

else 
    error(['no rotation matrix for axis', num2str(axis)]);
end
