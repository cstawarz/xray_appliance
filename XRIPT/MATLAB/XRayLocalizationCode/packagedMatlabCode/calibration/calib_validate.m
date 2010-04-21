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
% Validation_RHS is a vector of extracted features (or a struct with extracted features, see readme.doc) from images of the
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
%convert to vector form. If vector, leave alone
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
    
    
       
%%these numbers dont matter, just building a dummy system to call some
%%XRAYSystem methods. 
detectors = 2;
rotationSpread = 0;
detectorDistances = [1; 1];
detectorAngles = [0,0,0; 0,0,0];
sourceDistances = [0; 0];

[validationSystem]...
    = ...
xrg_buildUnperturbedSystem1(...
    detectors,...
    rotationSpread,...
    detectorDistances,...
    sourceDistances);

xrg_addFiducials(validationSystem, validationPattern); 

%%comparing the reconstructed position to the actual position- forming the
%%validationData struct
count = 1;
numFids = reconstructedSystem.getNumberOfFiducials();

for target = 1:numFids
    for f1 = 1:numFids
        for f2 = 1:numFids
            for f3 = 1:numFids 
                if (target~=f1&&target~=f2&&target~=f3&&f1~=f2&&f1~=f3&&f2~=f3)
                    
                    expectedPosition = xrg_getFiducialLocationRelativeToFiducialFrame...
                        (reconstructedSystem,target,f1,f2,f3);
                    
                    actualPosition  = xrg_getFiducialLocationRelativeToFiducialFrame...
                        (validationSystem,target,f1,f2,f3);
                    
                    relXError = actualPosition(1) - expectedPosition(1);
                    relYError = actualPosition(2) - expectedPosition(2);
                    relZError = actualPosition(3) - expectedPosition(3);
                    relError  = norm(actualPosition - expectedPosition);
                    
                    validationTable(count,1) = relError;
                    validationTable(count,2) = target;
                    validationTable(count,3) = f1;
                    validationTable(count,4) = f2;
                    validationTable(count,5) = f3;
                    
                    allRelativeErrors(count) = relError;
                    allRelativeXErrors(count) = relXError;
                    allRelativeYErrors(count) = relYError;
                    allRelativeZErrors(count) = relZError;
                    
                    i = strcat('f', num2str(target)); 
                    j = strcat('f', num2str(f1));
                    k = strcat('f', num2str(f2));
                    l = strcat('f', num2str(f3));
                    
                    validationData.relError.(i).frame.(j).(k).(l) = relError;
                    validationData.relXError.(i).frame.(j).(k).(l) = relXError;
                    validationData.relYError.(i).frame.(j).(k).(l) = relYError;
                    validationData.relZError.(i).frame.(j).(k).(l) = relZError;  
                    
                    count = count +1;
                end
            end
        end
    end
end

validationData.allRelativeErrors = allRelativeErrors;
validationData.allRelativeXErrors = allRelativeXErrors;
validationData.allRelativeYErrors = allRelativeYErrors;
validationData.allRelativeZErrors = allRelativeZErrors;
numFids = reconstructedSystem.getNumberOfFiducials();

validationFidLocations   = xrg_getFiducialCenters(validationSystem);
reconstructedFidLocation = xrg_getFiducialCenters(reconstructedSystem);

for i = 1:numFids
    fld = strcat('f', num2str(i));
    validationData.actualPosition.(fld)   = validationFidLocations(i,:);%validationSystem.getFiducialLocation(i-1);
    validationData.expectedPosition.(fld) = reconstructedFidLocation(i,:); 
end

count = 1;
 fivekFilteredErrors = [];
    fids = reconstructedSystem.getNumberOfFiducials();
    for i = 1:fids
        for j = 1:fids
            for k = 1:fids
                for l = 1:fids

                    if (i~=j&&i~=k&&i~=l&&j~=k&&j~=l&&k~=l)
                        str0 = strcat('f', num2str(i));
                        str1 = strcat('f', num2str(j));
                        str2 = strcat('f', num2str(k));
                        str3 = strcat('f', num2str(l));
                        
%                         f1 = validationData.expectedPosition.(str1);
%                         f2 = validationData.expectedPosition.(str2);
                        
                        %str
                        if...
                                ((norm(validationData.expectedPosition.(str1) - validationData.expectedPosition.(str2))>5000)&& ...
                                (norm(validationData.expectedPosition.(str1) - validationData.expectedPosition.(str3))>5000)&& ...
                                (norm(validationData.expectedPosition.(str2) - validationData.expectedPosition.(str3))>5000))
                            
                                additionalError = validationData.relError.(str0).frame.(str1).(str2).(str3);
                                fivekFilteredErrors = [fivekFilteredErrors, additionalError];

                                validationTableFiveK(count,1) = additionalError;
                                validationTableFiveK(count,2) = i;
                                validationTableFiveK(count,3) = j;
                                validationTableFiveK(count,4) = k;
                                validationTableFiveK(count,5) = l;
                                count = count+1;
                        end
                    end
                end
            end
        end
    end
    %%adding the fiveKFilteredErrors,
   validationData.fivekFilteredErrors = fivekFilteredErrors;
   
   %%adding sorted table of errors
   [Y,I] = sort(validationTable);
   indexOrder = I(:,1); %%sorting by relError
   for i = 1:size(validationTable,1)
    sortedTable(i,:) = validationTable(indexOrder(i),:);
   end
   validationData.validationTable = sortedTable;
   
   %%adding sorted table of fivek errors
   [Y,I] = sort(validationTableFiveK);
   indexOrder = I(:,1); %%sorting by relError
   for i = 1:size(validationTableFiveK,1)
    sortedTableFiveK(i,:) = validationTableFiveK(indexOrder(i),:);
   end
   validationData.validationTableFiveK = sortedTableFiveK;

