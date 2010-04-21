%% globals- call this first before calling any xray functions.
%
%
% homeDirectory,dataDirectory need to be modified by user of the code
homeDirectory = '/Users/paul/Desktop/mengStuff/sandbox/XRay/XRayLocalizationCode/packagedMatlabCode/';
dataDirectory = [homeDirectory, '../../XRayLocalizationData/'];

addpath(homeDirectory);
temp = strcat(homeDirectory, 'general/');
addpath(temp);
temp = strcat(homeDirectory, 'CTprocessing/');
addpath(temp);
temp = strcat(homeDirectory, 'calibration/');
addpath(temp);
temp = strcat(homeDirectory, 'calibration/simulation/');
addpath(temp);
temp = strcat(homeDirectory, 'reconstruction/');
addpath(temp);
temp = strcat(homeDirectory, 'reconstruction/simulation/');
addpath(temp);
temp = strcat(homeDirectory, 'featureExtraction/');
addpath(temp);
temp = strcat(homeDirectory, 'mriCoregistration/');
addpath(temp);
temp = strcat(homeDirectory, 'docs/');
addpath(temp);

clear temp

%%setting up a path to java jars
javarmpath(strcat(homeDirectory, 'general/Simulator.jar')); %%removing in case one already exists
javaaddpath(strcat(homeDirectory, 'general/Simulator.jar'));