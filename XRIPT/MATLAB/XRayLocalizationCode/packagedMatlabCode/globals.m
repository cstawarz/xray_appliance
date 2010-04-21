%% globals- call this first before calling any xray functions to setup
%% paths, javapath
%
%
% homeDirectory, dataDirectory need to be modified by user of the code
% homeDirectory =
dataDirectory = [homeDirectory, '/../../XRayLocalizationData/'];
    
addpath(homeDirectory);
temp = strcat(homeDirectory, '/general/');
addpath(temp);
temp = strcat(homeDirectory, '/calibration/');
addpath(temp);
temp = strcat(homeDirectory, '/reconstruction/');
addpath(temp);
temp = strcat(homeDirectory, '/mriCoregistration/');
addpath(temp);

clear temp

%%setting up a path to java jars
javarmpath(strcat(homeDirectory, '/general/Simulator.jar')); %%removing in case one already exists
javaaddpath(strcat(homeDirectory, '/general/Simulator.jar'));

