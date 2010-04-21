function ...
    [validationData,...
    expectedCalibratedSystem,...
    reconstructedValidationPattern] = ...
    calib_validate(expectedCalibratedSystem, validationPattern, validation_RHS)

%% calib_validate: use to evaluate performance of reconstruction
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [validationData,...
%     expectedCalibratedSystem,...
%     reconstructedValidationPattern] = ...
%     calib_validate(expectedCalibratedSystem, validationPattern, validation_RHS)
%
% 
% Validation is a test of how well our system is calibrated- 
% we pass in a calibrated system and see how well we can reconstruct a known fiducial pattern.
% The reconstructed pattern is compared to the known fiducial pattern.
% This method calls recon_reconstruct to get reconstructed centers, 
% localizes the reconstructed centers with respect to one another,
% localizes the true centers with respect to one another,
% and outputs some measures of the difference between true and reconstructed localizations. 
%
% Let reconRelPos(i,j,k,l) be the relative reconstructed position of
%  the ith fiducial with respect to a reference frame formed 
%  by the jth, kth, and lth fiducial (in that order)  
% 
%  Let actualRelPos(i,j,k,l) be the relative ctData position of the ith
%  fiducial with respect to a reference frame formed by the jth, kth, and lth
%  fiducial (in that order)
% 
% see localization for how frame is formed 
% 
%  Let E(i,j,k,l) be the distance between reconRelPos(i,j,k,l) and
%  actualRelPos(i,j,k,l).
%
%  Let relXError(i,j,k,l) be the x distance between reconRelPos(i,j,k,l) and
%  actualRelPos(i,j,k,l)
%
%  Let relYError(i,j,k,l) be the y distance between reconRelPos(i,j,k,l) and
%  actualRelPos(i,j,k,l)
%
%  Let relZError(i,j,k,l) be the z distance between reconRelPos(i,j,k,l) and
%  actualRelPos(i,j,k,l)
%  
% See doc_calvalDemo for an example of validation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% expectedCalibratedSystem  is our assumed system after calibration.
%
% ValidationPattern is an n*3 array of centerpoints that is the ct data version of the validation pattern.
%
% Validation_RHS is a vector of extracted features from images of the
% validation object. The order of the extracted features must be the same as the order
% of the validation pattern.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:
%
% Returns a validationData struct containing the data:  
% 
% reconstructedFiducialLocation1
%
% reconstructedFiducialLocation2, ... 
%
% reconstructedFiducialLocationN,
%
% relativeError(i,j,k,l),                       (for all i,j,k,l s.t. i!=j!=k!=l,) 
%
% relXError(i,j,k,l),
%
% relYError(i,j,k,l),
%
% relZerror(i,j,k,l),
%
% allRelativeErrors               (the indexed relative errors concatenated together)
%
% allRelativeXErrors,
%
% allRelativeYErrors,
%
% allRelativeZErrors
%
% fivekFilteredErrors- all the relativeError(i,j,k,l) s.t. the fiducial
% frame points j,k,l are all at least 5000 microns aprt from one another
%
% fiducialLocation(i) for all i
%
% validationTable- a table describing all errors where the first column is
% error, the second column is the target index, the third column is the
% first fiducial index, the fourth column is the second fiducial index, and
% the 5th column is the third fiducial index
%
% expectedCalibratedSystem is the system after reconstruction.
% reconstructedValidationPattern is the pattern that the algorthim reconstructs
%
%
% 
% Also returns:
%
% ExpectedCalibratedSystem is the system after reconstruction of the validation object; 
% that is it should be a calibrated system containing reconstructed points that should be 
% like those in the validation object. 
% 
% ReconstructedValidationPattern is an n*3 set of centerpoints that is the reconstructed version
% of the validation pattern- compare this if needed to the input validationPattern 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requires that the expectedCalibratedSystem is correctly calibrated with
% respect to the images that generated the validationPattern 
%
% Requires that the extracted features (2d centers) encoded in the validateRHS are in the same order
% as the extracted features (3d centers) in the CT_orderedCenters.
%
% Requires also that the validationObject_RHS encodes features from the same object
% as CT_orderedCenters (our ct data is from the same object as our image
% data)
%
% Modifies: expectedCalibratedSystem, emptying it of any fiducials it has,
% and adding new fiducials.  

%%checking whether input is nested struct format, struct or vector format. If struct or nested struct,
%convert to vector form
validation_RHS = xrg_RHSVerbose2Vector(validation_RHS);

%%checking to see that the number of fiducials in validation pattern is
%%same as number of fiducials in the RHS
if(size(validationPattern,1)~=(size(validation_RHS,1)/(expectedCalibratedSystem.getNumberOfSDP()*2)))
    error('number of fiducials in validation pattern does not match number of fiducials in RHS');
end


xrg_emptySystem(expectedCalibratedSystem); %%emptying fiducials if there already were any


%%reconstructing- this adds enough fiducials to the system to match the RHS
%%perturbs the fiducials in expectedCalibratedSystem untill output matches RHS 
[reconstructedSystem, reconstructedValidationPattern, resnorm, iters, exitflag] = ...
    recon_reconstruct(expectedCalibratedSystem, validation_RHS); 

%     if (exitflag~=1)
%         error('validation failed! reconstruction did not converge quickly enough')
%     end
    
clear targetCenters
clear destCenters

numCenters = size(reconstructedValidationPattern,1);

for i = 1:size(reconstructedValidationPattern,1)
    
    firstUpperBound = i-1;
    secondLowerBound = i+1;
    
    targetCenters = [];
    destCenters = [];
    if (firstUpperBound~=0)
        targetCenters = reconstructedValidationPattern(1:firstUpperBound,:);
        destCenters = validationPattern(1:firstUpperBound,:);
    end
    
    if(secondLowerBound ~= numCenters+1)
        targetCenters = [targetCenters; reconstructedValidationPattern(secondLowerBound:numCenters,:)];
        destCenters = [destCenters; validationPattern(secondLowerBound:numCenters,:)];
    end
    
    
    localizationPoint = reconstructedValidationPattern(i,:);
    coregLocInCTFrame = mri_target2DestFrameTransform(localizationPoint, targetCenters, destCenters);
    trueInCTFrame = validationPattern(i,:);
    nrm = norm(coregLocInCTFrame - trueInCTFrame);
    deltax = coregLocInCTFrame(1) - trueInCTFrame(1);
    deltay = coregLocInCTFrame(2) - trueInCTFrame(2);
    deltaz = coregLocInCTFrame(3) - trueInCTFrame(3);
    
    
    fidString = ['f', num2str(i)];
    validationData.(fidString).relError = nrm;
    validationData.(fidString).relX = deltax;
    validationData.(fidString).relY = deltay;
    validationData.(fidString).relZ = deltaz;   

    validationData.allRelativeErrors = [];
    validationData.allRelativeXErrors = [];
    validationData.allRelativeYErrors = [];
    validationData.allRelativeZErrors = [];
       
    validationData.allRelativeErrors = [validationData.allRelativeErrors, nrm];
    validationData.allRelativeXErrors = [validationData.allRelativeXErrors, deltax];
    validationData.allRelativeYErrors = [validationData.allRelativeYErrors, deltay];
    validationData.allRelativeZErrors = [validationData.allRelativeZErrors, deltaz];
end


numFids = reconstructedSystem.getNumberOfFiducials();

reconstructedFidLocation = xrg_getFiducialCenters(reconstructedSystem);

for i = 1:numFids
    fld = strcat('f', num2str(i));
    validationData.(fld).actualPosition   = validationPattern(i,:);%validationSystem.getFiducialLocation(i-1);
    validationData.(fld).expectedPosition = reconstructedFidLocation(i,:); 
end
