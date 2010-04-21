function [] = xrg_addSourceDetectorPair(...
expectedSystem,...
sourceDistance,...
detectorDistance,...
rotation,...
detectorRows,...
detectorCols,...
pixelWidth,...
pixelHeight)

%%xrg_addSourceDetectorPair: add a source detector pair to xry sysstem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function [] = xrg_addSourceDetectorPair(...
% expectedSystem,...
% sourceDistance,...
% detectorDistance,...
% rotation,...
% detectorRows,...
% detectorCols,...
% pixelWidth,...
% pixelHeight)
%
% Use this function to add non-default sourceDetector pairs to an XRay
% system. Adds source detecotr pairs along xaxis and then rotates them by
% rotations degrees about the z axis counterclockwise relative to the
% x-axis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs: 
%
% expectedSystem: the Xray system to which we want to add a source detector
% pair
%
% sourceDistance: the distance at which the source will be added to the xray system-
% the center of the source will be added at (-sourceDistance, 0,0), and
% then rotated by rotations about the z axis counterclockwise
%
% detectorDistance: the distance at which the detector will be added to the
% XRaySystem- the center of the detector will be added at (0,0,
% detectorDistance) and then rotated by rotatoins about the z axis
% counterclockwise
%
% rotation: the amount of rotation relative to the xaxis (+x is 0 degrees) applied to an sdp whose source is at 
% (-sourceDistance, 0,0) and whose detector is at (detectorDistance, 0, 0)
% 
% detectorRows: the number of rows of pixels in the added detector.
%
% detectorCols: the number of colls of pixels in the added detector
%
% pixelWidth: the width of a pixel in the added detector
%
% pixelHeight: the height of a pixel in the added detector
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Ouputs: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modifies: expectedSystem to have another sdp
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires:
% If there are no detectors yet in the system, the first sdp
% added  must have a rotation of 0
%

if (expectedSystem.getNumberOfSDP() == 0&&(rotation ~=0))
    error('First sdp must have a rotation of 0.')
end

expectedSystem.addDefaultSourceDetectorPair(...
    sourceDistance,...
    detectorDistance,...
    rotation,...
    detectorRows,...
    detectorCols,...
    pixelWidth,...
    pixelHeight);
end
