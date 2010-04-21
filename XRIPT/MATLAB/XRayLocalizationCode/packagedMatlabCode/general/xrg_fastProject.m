function [projection] = fastProject(system, pixelRadius, detectorIndex)
%% xrg_fastProject: quick approximation of image projection in xray system
%%
%%%%%%%%%%%%%%%%%%%
%
% [projection] = fastProject(system, pixelRadius, detectorIndex)
%
% Projects all the fiducials already in the system- must call addFiducials
% for there to be any projections.
% projects them as squares of value 1, and radius pixelRadius at the ideal centers of projection
% onto the detectorIndxth array. returns the 2d projection array.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% inputs: 
%
% system: XRAYSystem which will create simulated projections
%
% pixelRadius: the radius of square projections of fiducials
%
% detectorIndex: the index of the detector in the system from which we want
% to get a simulated projection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% outputs:
%
% projection: an array of double values with the same dimension as the detector indxth
% detector array. fiducials are projected as squares with value 1, and
% radius pixelRadius, centered at their ideal centers of projection. 
%
%

    projection = system.project4(detectorIndex - 1, pixelRadius); %% - 1 becuase of java indexing
end