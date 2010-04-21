function [projection] = xrg_slowProject(system, discretization, detectorIndex)

%% xrg_slowProject: use this to get a more accurate projection of fiducials in xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [projection] = slowProject(system, discretization, detectorIndex)
% 
% Discretizes each fiducial in the system as a sphere composed of voxels,
% and then projects the voxels individually to get better projection than in fast project.
% 
% Each fiducial is composed of discretization voxels from its center to its
% radius- the larger the value of discretization, the more accurate the
% projection, but the slower the projection. 
%
% Each voxel has an attenuation value of 1, and the pixel containing the
% projection point of each voxel accumulates the attenuation associated
% with that voxel together with the attenuations of any other voxel that
% has projected onto that pixel. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% system: XRAYSystem which will create simulated projections
%
% discretization: the radius of square projections of fiducials
%
% detectorIndex: the index of the detector in the system from which we want
% to get a simulated projection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% outputs:
%
% projection: an array of double values with the same dimension as the detector indxth
% detector array. fiducials are projected using a voxel projection model-
% see as described above
%
% returns a projection onto the detectorIndexth detector, discretizing the
% fiducial to have discretization voxels from its center to its radius-
% the larger the value of discretization, the more accurate the
% projection, but the slower the projection.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires: 
%
% There must be fiducials in the system.
% If there are no fiducials in the system, returns 0 array. 
%
% Make sure to call xrg_setRadius before using this method to make sure fiducials don't
% have 0 radius, which is their default value. 0 radius fiducials will project as single pixels.  
%

projection = system.project2(discretization, detectorIndex-1);

end