function[] = xrg_emptySystem(expectedSystem)

%% xrg_emptySystem: cleans system of fiducials and any fiducial collection movement
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function[] = xrg_emptySystem(expectedSystem)
%
% given an expectedSystem, removes all fiducials from it. Recenters the
% fiducial collection at a translation of 0,0,0 and rotation of 0,0,0. see
% setSystemDeltas.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% expectedSystem: the system from which we are removing fiducials and the
% and recentering the fiducial collection
%
%%%%%%%%%%%%%%%%%
% Modifies:
%
% expected sytem- removing all fiducials and perturbations to the fiducial
% colleciton. 
%


expectedSystem.emptyFids();

systemDeltaStruct = xrg_getSystemDeltas(expectedSystem);

systemDeltaStruct.fiducialCollection.xTranslation = 0;

systemDeltaStruct.fiducialCollection.yTranslation = 0;

systemDeltaStruct.fiducialCollection.zTranslation = 0;

systemDeltaStruct.fiducialCollection.rot1 = 0;

systemDeltaStruct.fiducialCollection.rot2 = 0;

systemDeltaStruct.fiducialCollection.rot3 = 0;

xrg_setSystemDeltas2(expectedSystem, systemDeltaStruct); %%struct form of the set statement
end
