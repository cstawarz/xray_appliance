function [expectedSystem]...
    = ...
    xrg_buildUnperturbedSystem1(...
    detectors,...
    rotationSpread,...
    detectorDistances,...
    sourceDistances)

%% xrg_buildUnperturbedSystem1: builds an xray system for use in recon/calib/validation routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function [expectedSystem]...
%     = ...
%     buildUnperturbedSystem1(...
%     detectors,...
%     rotationSpread,...
%     detectorDistances,...
%     sourceDistances)
%
%
% Creates a system with "detectors" number of default sourceDetectorPairs, laid out in the
% x-y plane, surrounding the origin, at distances as specified by
% sourceDistances and detectorDistances. A default source detector pair is
% one in which the detectors are 1000*1024, with a pixel height and
% width of 48 microns
%
% These sourceDetectorPairs are evenly rotated counterClockwise over rotationSpread,
% about the z axis.
%
% For example, 2 sdps rotated over a 90 degree rotation spread would be at right
% angles to one another in the x-y plane. 3 detectors rotated over a 90 degree
% rotationSpread would be arranged at intervals of 45 degrees- one at 0
% degrees, one at 45 degrees, and one at 90 degrees. 
% 
% The first sdp is always laid along the x axis, with the axis of rotation
% for the subsequent sdps always being the +z axis
%
% see xrg_addSourceDetectorPair for how to add non default detectors to the
% xray system. See readme.doc for more documentation on building Xray
% systems. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% inputs:
%
% detectors: the number of sdp's that we want in our xray system.
%
% rotation spread: the counterclockwise angular separation from the first to the last sdp. 
%
% detecotrDistances: detectorDistance(i) is the distance from the origin of
% the ith detector
%
% sourceDistances: sourceDistances(i) is the distance from the origin of the
% ith source
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% outputs:
%
% expectedSystem is an XRAY system after the sdps are built.
%
%

expectedSystem = Simulator.XRAYSystem.BuildDefault();

%% Setting parameters in ExpectedSysteqm
%% adding sourceDetector pairs, and rotating them
for i = 1:detectors
%  expectedSystem.addDefaultSourceDetectorPair...
%         (sourceDistances(i), detectorDistances(i));
%     expectedSystem.rotateSDP(rotationSpread*(i-1), i-1);
    expectedSystem.addDefaultSourceDetectorPair...
          (sourceDistances(i), detectorDistances(i), rotationSpread*(i-1));
   

end
