
%% xrg_buildSampleSystem: builds a sample xray system 
%

function [sample] = xrg_buildSampleSystem()

% detectors = 2;
% rotationSpread =  -110;
% detectorDistances = [275000; 180000];
% sourceDistances = [210000; 180000];

detectors = 2;
rotationSpread =  -90;
detectorDistances = [275000; 225000];
sourceDistances = [182000; 205000];

sample = ...  
    xrg_buildUnperturbedSystem1(...
    detectors,...
    rotationSpread,...
    detectorDistances,...
    sourceDistances);


