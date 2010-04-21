%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% calib_tester
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%
%% Used to call simulateAndReconstruct with our actual calibration pattern,
%% to see how well out calibrationPattern works, given some range of system
%% Deltas that the simulatedActualSystem can take, and also given a ct
%% resolution and imaging delta
%%
%%
%%
%% The way this simulation works is that we build unpertubed acutal and
%% expected systems (they are the same initially).
%%
%% Then we perturb the actual system across various geometrical parameters. We also perturb the
%% actual calibration pattern to reflect the fact that CT is not precise
%%
%% We then extract a simulated RHS from the perturbed actual system, and
%% see how well calibration works, using the unperturbed expected system as
%% a guess, and our unpertrubed expected calibration pattern.
%%
%% We have 2 measures of how well calibration worked- we use our validation
%% function, with the simulated acutal fiducial locations as ground truth,
%% and reconstructed fiducial positions as the patterns that we compare.
%%
%% we also can compare the system deltas from the simulated actual system
%% to those from the expected system- they should be the same following
%% calibration.

clear all;
pack;
globals


load (strcat(dataDirectory, '/processedCTData/cal1_CT_orderedCenters')); %%our actual aclibration object
calibrationPattern = cal1_CT_orderedCenters;

load (strcat(dataDirectory, '/processedCTData/test6_CT_orderedCenters')); %%our actual testing object
validationPattern = test6_CT_orderedCenters;

%%resetting the seed for simulation- uniform distribution seed
rand('state',sum(100*clock));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CHANGE PARAMS BELOW TO TRY OUT CALIBRATION SIMULATIONS
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ctDelta = 2; %2; %% in microns
calibOutputDelta = .4;%.5; %%in pixels, not microns!
reconOutputDelta = .4;
detectors = 2;
rotationSpread = 90;

detectorDistances = [205000; 275000];
sourceDistances = [225000; 182000];


%%d1 first row, d2 second row
%%polar, azimuthal, normal
detectorAngleDeltas = [7.0000000, 7.000000, 7.0000000;...
    7.000000,  7.000000,  7.0000000];

sourceDistanceDeltas = [0.0000000, 0.000000, 0.0000000;...
    0.0000000, 0.000000, 0.0000000];

fidCollectionRotationDeltas = [360.000000,20.000000,20.000000];

%%normal, horizontal, vertical
fidCollectionTranslationDeltas = [2000,3000,5000];


%%normal, horizontal, vertical
sdpTranslationDeltas = [10000,10000,10000;...
    10000,10000,10000];

sdpRotationDeltas = [5,5,5;...
    5,5,5];

%                  sdpRotationDeltas = [0,0,0;...
%                      5,0,5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%END OF PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%Simulation engine


%%building an unperturbed expected  system
expectedSystem = xrg_buildUnperturbedSystem1(...
    detectors,...
    rotationSpread,...
    detectorDistances,...
    sourceDistances);
xrg_addFiducials(expectedSystem, calibrationPattern);


%%creating a perturbed system in which all fiducials project onto arrays
hasProjected = 0;
iterations = 0;

%%keep trying to make a new perturbed system untill all fiducials
%%sucessfully project onto all arrays
while (hasProjected == 0&&iterations<100)

    %%building an unperturbed simulated system
    simulatedActualSystem = xrg_buildUnperturbedSystem1(...
        detectors,...
        rotationSpread,...
        detectorDistances,...
        sourceDistances);
    xrg_addFiducials(simulatedActualSystem, calibrationPattern);

    %%perturbing simulatedActualSystem
    originalDeltas = xrg_getSystemDeltas(simulatedActualSystem); %% this should be all 0's
    for i = 1:detectors
        %%first sdp case
        if (i==1)
            detstr = ['det', num2str(i)];
            originalDeltas.([detstr, 'TranslationFromSource']) = randCenteredAtZero1(detectorDistanceDeltas(i));
            originalDeltas.([detstr, 'PolarAngle']) = randCenteredAtZero1(detectorAngleDeltas(i,1));
            originalDeltas.([detstr, 'AzimuthalAngle']) = randCenteredAtZero1(detectorAngleDeltas(i,2));
            %%other sdp cases
        else
            %%detector perturbations
            detstr = ['det', num2str(i)];
            originalDeltas.([detstr, 'TranslationFromSource']) = randCenteredAtZero1(detectorDistanceDeltas(i));
            originalDeltas.([detstr, 'PolarAngle'])            = randCenteredAtZero1(detectorAngleDeltas(i,1));
            originalDeltas.([detstr, 'AzimuthalAngle'])        = randCenteredAtZero1(detectorAngleDeltas(i,2));
            originalDeltas.([detstr, 'NormalAngle'])           = randCenteredAtZero1(detectorAngleDeltas(i,3));

            %%sdp translation pertrubations
            sdpstr = ['sdp', num2str(i)];
            originalDeltas.([sdpstr, 'XTranslation'])          = randCenteredAtZero1(sdpTranslationDeltas(i,1));
            originalDeltas.([sdpstr, 'YTranslation'])          = randCenteredAtZero1(sdpTranslationDeltas(i,2));
            originalDeltas.([sdpstr, 'ZTranslation'])          = randCenteredAtZero1(sdpTranslationDeltas(i,3));

            %%sdp angle perturbations
            originalDeltas.([sdpstr, 'PolarRotation'])            = randCenteredAtZero1(sdpRotationDeltas(i,1));
            originalDeltas.([sdpstr, 'AzimuthalRotation'])        = randCenteredAtZero1(sdpRotationDeltas(i,2));
        end
    end

    %%perturbing the calibration pattern in space
    originalDeltas.fiducialCollection.xTranslation             = randCenteredAtZero1(fidCollectionTranslationDeltas(1));
    originalDeltas.fiducialCollection.yTranslation             = randCenteredAtZero1(fidCollectionTranslationDeltas(2));
    originalDeltas.fiducialCollection.zTranslation             = randCenteredAtZero1(fidCollectionTranslationDeltas(3));

    originalDeltas.fiducialCollection.rot1                     = randCenteredAtZero1(fidCollectionRotationDeltas(1));
    originalDeltas.fiducialCollection.rot2                     = randCenteredAtZero1(fidCollectionRotationDeltas(2));
    originalDeltas.fiducialCollection.rot3                     = randCenteredAtZero1(fidCollectionRotationDeltas(3));

    %%perturbing the relative fiducial positions of the calibration pattern
    for i = 1:simulatedActualSystem.getNumberOfFiducials()
        %%perturbing each fiducial individually by ct delta
        t1 = randCenteredAtZero1(ctDelta);
        t2 = randCenteredAtZero1(ctDelta);
        t3 = randCenteredAtZero1(ctDelta);
        simulatedActualSystem.perturbLightFiducialPosition(t1, t2, t3, i-1);
    end
    xrg_setSystemDeltas(simulatedActualSystem, originalDeltas);
    
    %%getting a simulated calibration RHS from the simulated pertrubed system
    simulatedCalibrationRHSVerbose = xrg_getRHS(simulatedActualSystem);

    simulatedCalibrationRHS = simulatedCalibrationRHSVerbose.RHS...
    + randCenteredAtZero2(calibOutputDelta,...
    size(simulatedCalibrationRHSVerbose.RHS,1),...
    size(simulatedCalibrationRHSVerbose.RHS,2)); %%perturbing the RHS by a uniform centered at zro, of max value calibOutputDelta
    
    %%testing to see if RHS is inbounds (non negative, not too large, etc)
    if (Simulator.OutputGenerator.outputInBounds(simulatedCalibrationRHS, expectedSystem))
        hasProjected = 1;
    else
        iterations = iterations + 1;
        clear simulatedActualSystem;
        pack
    end
end

% clear originalDeltas

%%calibrating if it calibrationRHS is inbounds. 
expectedSystem = calib_calibrate(expectedSystem, calibrationPattern, simulatedCalibrationRHS);
xrg_getSystemDeltas(expectedSystem);

%%running a validation

%%generating validation RHS 
xrg_emptySystem(simulatedActualSystem);
xrg_addFiducials(simulatedActualSystem, validationPattern);
%%getting a simulated recon rHS
simulatedReconRHSVerbose = xrg_getRHS(simulatedActualSystem);

    simulatedReconRHS = simulatedReconRHSVerbose.RHS...
    + randCenteredAtZero2(reconOutputDelta,...
    size(simulatedReconRHSVerbose.RHS,1),...
    size(simulatedReconRHSVerbose.RHS,2)); %%perturbing the RHS by a uniform centered at zro, of max value calibOutputDelta

clear simulatedActualSystem
pack

%%validating with the calibrated system
[validationData, expectedSystem, reconstructedValidationPattern] = ...
    calib_validate(expectedSystem, validationPattern, simulatedReconRHS);





