%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% getElectrodeLocationRelativeToFiducialFrame2
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% function[relativeLocation] =
%% getElectrodeLocationRelativeToFiducialFrame2(expectedSystem)
%%
%% creates a reference frame using the center of mass of
%% fiducials 2:n of the expectedSystem as an origin, 
%% pca component 1 of fiducials 2:n as basis1,
%% pca component 2 of fiducials 2:n as basis2,
%% cross product of 1 and 2 as basis3
%%
%% returns location of fiducial1 with respect to this newly created frame
%%
%% This method doesnt seem to work very well... dont use it without testing
%% further. 
%%

function[relativeLocation] = getElectrodeLocationRelativeToFiducialFrame2(expectedSystem)


fids = expectedSystem.getNumberOfFiducials();

ex = expectedSystem.getElectrodeLocation().x;
ey = expectedSystem.getElectrodeLocation().y;
ez = expectedSystem.getElectrodeLocation().z;
electrodeLocation = [ex, ey, ez]'; 

origin = [0,0,0]';


for i = 2:fids

        location = expectedSystem.getFiducialLocation(i-1);
        origin(1) = origin(1) + location.x;
        origin(2) = origin(2) + location.y;
        origin(3) = origin(3) + location.z;
        data(i-1,1) = location.x;
        data(i-1,2) = location.y;
        data(i-1,3) = location.z;

end

% electrodeLocation
origin = origin/(fids - 1);
%%oldData = data
data(:,1) = data(:,1) - origin(1);
data(:,2) = data(:,2) - origin(2);
data(:,3) = data(:,3) - origin(3);
% data
rhs = electrodeLocation - origin;



[D, L, E]  = pcacov(data);
%%pause
b1 = D(:,1);
b2 = D(:,2);
if (b2(1)<0) 
    b2 = -b2;
end
b2 = b2 - dot(b1,b2)*b1;
b3 = cross(b1, b2);


b1 = b1/norm(b1);
b2 = b2/norm(b2);
b3 = b3/norm(b3);
A = [b1,b2,b3];
%%L
%%E

rel = A\rhs;
relativeLocation = javax.vecmath.Point3d(rel(1), rel(2), rel(3));

    

