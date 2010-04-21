function [newSystem] = xrg_setSystemDeltas2(oldSystem, systemDeltaStruct)

%% xrg_setSystemDeltas2: same as setSystemDeltas, only takes struct
%% argument
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%% Requires 2 detector system
%%
%% Modifies oldSystem to have system params as described by the
%% systemDeltaStruct.
%%
%% returns the modified newSystem


%%parsing the struct in to a vector form, and calling setSystemDeltas
firstOffset = 3; %%2 detector rotations + 1 detector translation
 
%% for every sdp beyond the first, there are
%% 2 detector rotations Translation and 3 sdp translations + 3 sdp rotations = 8
secondOffset = firstOffset + (oldSystem.getNumberOfSDP() - 1) * 9;
 
%%for the fiducial collection, there are 3 translations and 3 rotations that are unknown
thirdOffset = secondOffset + 6;

X(1,1) = systemDeltaStruct.det1TranslationFromSource;
X(2,1) = systemDeltaStruct.det1PolarAngle;
X(3,1) = systemDeltaStruct.det1AzimuthalAngle;

for i =2:oldSystem.getNumberOfSDP()
    sdpi = oldSystem.getSDP(i-1); %%java indexing - 1
    deti = sdpi.getDetector();
    detstr = ['det',num2str(i)];
    sdpstr = ['sdp',num2str(i)];
    
    X(firstOffset + (i-2)*9 + 1,1) = systemDeltaStruct.([detstr,'TranslationFromSource']); 
    
    X(firstOffset + (i-2)*9 + 2,1) = systemDeltaStruct.([detstr,'PolarAngle']); 
    
    X(firstOffset + (i-2)*9 + 3,1) = systemDeltaStruct.([detstr,'AzimuthalAngle']);
    
    X(firstOffset + (i-2)*9 + 4,1) = systemDeltaStruct.([detstr,'NormalAngle']); 
    
    X(firstOffset + (i-2)*9 + 5,1) = systemDeltaStruct.([sdpstr,'XTranslation']); 
    
    X(firstOffset + (i-2)*9 + 6,1) = systemDeltaStruct.([sdpstr,'YTranslation']);
    
    X(firstOffset + (i-2)*9 + 7,1) = systemDeltaStruct.([sdpstr,'ZTranslation']);
    
    X(firstOffset + (i-2)*9 + 8,1) = systemDeltaStruct.([sdpstr,'PolarRotation']); 
    
    X(firstOffset + (i-2)*9 + 9,1) = systemDeltaStruct.([sdpstr,'AzimuthalRotation']);
end


X(secondOffset + 1,1) = systemDeltaStruct.fiducialCollection.xTranslation;

X(secondOffset + 2,1) = systemDeltaStruct.fiducialCollection.yTranslation;

X(secondOffset + 3,1) = systemDeltaStruct.fiducialCollection.zTranslation;

X(secondOffset + 4,1) = systemDeltaStruct.fiducialCollection.rot1;

X(secondOffset + 5,1) = systemDeltaStruct.fiducialCollection.rot2;

X(secondOffset + 6,1) = systemDeltaStruct.fiducialCollection.rot3;

newSystem = xrg_setSystemDeltas(oldSystem, X);
end