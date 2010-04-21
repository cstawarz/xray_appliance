function [newSystem] = xrg_setSystemDeltas(oldSystem, X)

%% xrg_setSystemDeltas: change the geometry of an xray system by perturbing it
%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [newSystem] = xrg_setSystemDeltas(oldSystem, X)
%
% Use this method to perturb the geometry of the xray system. X can either
% be a correctly formatted vector of system deltas, or a systemDeltasStruct
% (see xgr_getSystemDeltas)
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requires 2 detector system
%
% Modifies oldSystem to have system params as described by input vector
% Inputs: 
% X:
% X can either be in vector form:
%
%         * Input format: 
%         * fc = fiducial collection, s = source, d = detector, sdp = source detector pair
%         
%          [TranslationFromSource(d1),
%          RotationPolar(d1),
%          RotationAzimuthal(d1),...
%          
%          TranslationFromSource(di) for 2<=i<=n
%          RotationPolar(di),  
%          RotationAzimuthal(di),
%          RotationNormal(di), 
%          XTranslation(sdpi)
%          YTranslation(sdpi) 
%          ZTranslation(sdpi) 
%          RotationPolar(sdpi)
%          RotationAzimuthal(sdpi)....
%          
%          TranslationFromSource(dn),
%          RotationPolar(dn),  
%          RotationAzimuthal(dn),
%          RotationNormal(dn), 
%          XTranslation(sdpn)
%          YTranslation(sdpn) 
%          ZTranslation(sdpn) 
%          RotationPolar(sdpn)
%          RotationAzimuthal(sdpn)....
%          
%          XTranslation1(fc), 
%          YTranslation2(fc),
%          ZTranslation3(fc),
%          Rotation1(fc), 
%          Rotation2(fc),
%          Rotation3(fc)],
%          /
%
%       Or the delta input can be in struct form- call xrg_getSystemDeltas to get the present
%       delta struct, and modify the numbers, and pass the struct back in
%%%%%%%%%%%%%%
% output:
% newSystem: the modified oldSystem
%
%%%%%%%%%%%%%
%
% modifies: oldSystem
%

%%type dispatch for convenience
if(isa(X, 'struct'))
    xrg_setSystemDeltas2(oldSystem, X);
else
    if (oldSystem.getNumberOfSDP()<2)
        error('not enough detectors in the system');
    end

    firstOffset = 3; %%2 detector rotations + 1 detector translation

    %% for every sdp beyond the first, there are
    %% 2 detector rotations Translation and 3 sdp translations + 3 sdp rotations = 8
    secondOffset = firstOffset + (oldSystem.getNumberOfSDP() - 1) * 9;

    %%for the fiducial collection, there are 3 translations and 3 rotations that are unknown
    thirdOffset = secondOffset + 6;

    %%input checking
    if(thirdOffset~=size(X,1))
        thirdOffset
        size(X,1)
        error('input size of the vector is incorrect');
    end
    d0_t1 = X(1,1);
    oldSystem.setDetectorTranslation(d0_t1, 0, 0, 0); %% removes d0_t1 along focal axis
    d0_r1 = X(2,1);
    d0_r2 = X(3,1);
    oldSystem.setDetectorAngles(d0_r1, d0_r2, 0, 0);

    %%focal translation, detector rotation, sdp translation and rotation of detector pairs
    %%beyond the second sdp
    for sdp = 1:oldSystem.getNumberOfSDP-1
        di_t1 = X(firstOffset + 9 * (sdp - 1) + 1,1);
        oldSystem.setDetectorTranslation(di_t1, 0, 0, sdp);

        di_r1 = X(firstOffset + 9 * (sdp - 1) + 2,1);
        di_r2 = X(firstOffset + 9 * (sdp - 1) + 3,1);
        di_r3 = X(firstOffset + 9 * (sdp - 1) + 4,1);
        oldSystem.setDetectorAngles(di_r1, di_r2, di_r3, sdp);

        sdpi_t1 = X(firstOffset + 9 * (sdp - 1) + 5,1);
        sdpi_t2 = X(firstOffset + 9 * (sdp - 1) + 6,1);
        sdpi_t3 = X(firstOffset + 9 * (sdp - 1) + 7,1);
        oldSystem.setSDPTranslation(sdpi_t1, sdpi_t2, sdpi_t3, sdp);

        sdpi_r1 = X(firstOffset + 9 * (sdp - 1) + 8,1);
        sdpi_r2 = X(firstOffset + 9 * (sdp - 1) + 9,1);
        %%sdpi_r3 = X[firstOffset + 9 * (sdp - 1) + 8];
        oldSystem.setSDPRotation(sdpi_r1, 0, sdpi_r2, sdp);
    end

    %%translations and rotations for the fiducial collection
    fct1  = X(secondOffset  + 1,1);
    fct2  = X(secondOffset  + 2,1);
    fct3  = X(secondOffset  + 3,1);
    fcr1  = X(secondOffset + 4,1);
    fcr2  = X(secondOffset + 5,1);
    fcr3  = X(secondOffset + 6,1);
    oldSystem.getFids().fct1(fct1);
    oldSystem.getFids().fct2(fct2);
    oldSystem.getFids().fct3(fct3);
    oldSystem.getFids().fcr1(fcr1);
    oldSystem.getFids().fcr2(fcr2);
    oldSystem.getFids().fcr3(fcr3);
    newSystem = oldSystem;
end
end