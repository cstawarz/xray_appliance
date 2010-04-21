%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% calib_perturbFiducialCollection1
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%% function [] = calib_perturbFiducialCollection1(...
%         system,...
%         ctDelta,...
%         fiducialCollectionTranslationDeltas,...
%         fiducialCollectionRotationDeltas)
%  
% modifies the system: 
%
% perturbs invidual fiducials by up to ctDelta in each direction,
% and perturbs the whole fiducial collection of the system by up to
% fiducialcollectionTranslationDeltas(1) along the first basis,
% fiducialCollectionTranslationDeltas(2) along the second basis,
% fiducialCollectionTranslationDeltas(3) along the third basis.
%
% rotates by up to
% fiducialcollectionRotationDeltas(1) along the first axis,
% fiducialCollectionRotationDeltas(2) along the second axis,
% fiducialCollectionRotationDeltas(3) along the third axis.
%
% all random perturbation are distributed about 0, using uniform
% distribution


function [] = ...
    calib_perturbFiducialCollection1(...
        system,...
        ctDelta,...
        fiducialCollectionTranslationDeltas,...
        fiducialCollectionRotationDeltas)
    
        %%perturbing the entire fiducial collection
        trans1 = randCenteredAtZero1(fiducialCollectionTranslationDeltas(1,1))+system.getFCT1;
        trans2 = randCenteredAtZero1(fiducialCollectionTranslationDeltas(1,2))+system.getFCT2;
        trans3 = randCenteredAtZero1(fiducialCollectionTranslationDeltas(1,3))+system.getFCT3;
        rot1   = randCenteredAtZero1(fiducialCollectionRotationDeltas(1,1))+system.getFCR1;
        rot2   = randCenteredAtZero1(fiducialCollectionRotationDeltas(1,2))+system.getFCR2;
        rot3   = randCenteredAtZero1(fiducialCollectionRotationDeltas(1,3))+system.getFCR3;
        
        
        %%todo replace this call with an expectedSystem method
        expectedFids = system.getFids();
        
    expectedFids.fct1(trans1);
    expectedFids.fct2(trans2);
    expectedFids.fct3(trans3);
    expectedFids.fcr1(rot1);
    expectedFids.fcr2(rot2);
    expectedFids.fcr3(rot3);
    
    for i = 1:expectedFids.getNumberOfFiducials()
        %%perturbing each fiducial individually by ct delta
        t1 = randCenteredAtZero1(ctDelta);
        t2 = randCenteredAtZero1(ctDelta);
        t3 = randCenteredAtZero1(ctDelta);
        
        system.perturbLightFiducialPosition(t1, t2, t3, i-1);
    end
    
end