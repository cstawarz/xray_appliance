% %%%%%%%%%%%%%%%%%%%%%%%%
% %%
% %% calib_simulateValidation
% %%
% %%%%%%%%%%%%%%%%%%%%%%%%
% %
% %
% % Just test code for myself
% 
function [validationData, expectedCalibratedSystem, reconstructedValidationPattern] = calib_simulateValidation(expectedCalibratedSystem)

validationPattern = [3000,3000,2000;...
                    0,5000,-1000;...
                    5000,5000,-1000;...
                    0,5000,4000];
                    
                    validationPattern = [3000,3000,-1500;...
                        0,5000,-1000;...
                        5000,5000,-1000;...
                        5000,0000,-1000];
                    
xrg_emptySystem(expectedCalibratedSystem);
xrg_addFiducials(expectedCalibratedSystem,validationPattern);
validation_RHS = expectedCalibratedSystem.getIdealCentersOfProjection() + ...
    randCenteredAtZero2(1, 16,1);
                    
[validationData, expectedCalibratedSystem, reconstructedValidationPattern] = ...
    calib_validate(expectedCalibratedSystem, validationPattern, validation_RHS, 2);

% 
