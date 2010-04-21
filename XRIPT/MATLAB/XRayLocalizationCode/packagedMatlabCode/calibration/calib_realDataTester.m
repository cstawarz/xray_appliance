%%calib_realDataTester
%%
%%%%%%%%%%%%%%%%%%%%
%%
%% script used for testing calibration, validation on real data
%%

clear all
globals
pack

%%building a system guess according to measurements we made
detectors = 2;
rotationSpread = -90;
detectorDistances = [205000; 275000];
sourceDistances = [225000; 182000];

[expectedSystem]...
    = ...
xrg_buildUnperturbedSystem1(...
    detectors,...
    rotationSpread,...
    detectorDistances,...
    sourceDistances);

%%loads the variables RHS and RHS_Verbose into the workspace
load (strcat(dataDirectory, 'testAndCalImgs1/extractions/rhs_cal1_05090512_extraction1')); %%loading calib RHS
RHS_calibrate = RHS;

%%loads the variable cal1_CT_orderedCenters, and
%%cal1_CT_orderedCenterStruct into the workspace
load ([dataDirectory, 'processedCTData/cal1_CT_orderedCenters']); %%loading calibration pattern
calibrationPattern = cal1_CT_orderedCenters;
  
%%loads the variables RHS and RHS_Verbose into the workspace- be careful,
%%overwrites any RHS, or RHS_Verbose already in workspace. 
load ([dataDirectory, 'testAndCalImgs1/extractions/rhs_test6_05090512_extraction1']); %%loading a test RHS
RHS_Validate = RHS;

%%loads the variable test6_CT_orderedCenters, and
%%test6_CT_orderedCenterStruct intothe workspace
load ([dataDirectory, 'processedCTData/test6_CT_orderedCenters']); %%loading the validation pattern
validationPattern = test6_CT_orderedCenters;


%%creating validation data 
 [vdata,... %%validation data struct
    paramDeltas,... %%the params of calibration
    expectedCalibratedSystem,... %%the actual calibrated system
    reconstructedValidationPattern,... %%the validationPattern as reconstructed, (not by CT, by our data)
    calibrationExitFlag,... %%the exit flag of calibration
    calibrationIters ] = ... %% the number of iterations calibrations took
... 
calib_calibrateAndValidate...
     (expectedSystem,... %%our guess at the system
        RHS_calibrate,... %%the rhs for calibration
        calibrationPattern,... %%the pattern for calibration
        RHS_Validate,... %%the rhs for validation
        validationPattern); %% the validationPattern as extracted from CT data
  

e1 = mean(vdata.allRelativeErrors) %%mean of all the relative errors 
e2 = mean(vdata.fivekFilteredErrors) %%mean of all the relative errors where the frame includes only fiducials that are at least 5k apart
                