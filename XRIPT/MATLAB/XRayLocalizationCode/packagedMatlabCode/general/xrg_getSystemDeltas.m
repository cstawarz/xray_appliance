function [paramDeltaStruct, simpleDeltas] = xrg_getSystemDeltas(system)

%% xrg_getSystemDeltas: get a struct of deltas describing the perturbation
%% from system as originally built.
%%
%%%%%%%%%%%%%%%%%%%%%
%
% [paramDeltaStruct, simpleDeltas] = xrg_getSystemDeltas(system)
%
% forms a self describing struct of system deltas (perturbation from how it is built initially).
% the systemDeltas struct rewrites all rotations as angles between -180:180. Also returns a simple array
% form of the systemDeltas. When a system is first built, its system deltas
% should all be 0. see setSystemDeltas for how to perturb an xray System.
% see thesis for what the systemDelta parameters mean. 
% 
%%%%%%%
% Inputs: 
%
% system: the xray system whose perturbation we want to know
% [systemDeltaStruct, simpleDeltas] = calib_collectParams(system)
%
%%%%%%%%%%
%
% Outputs:
% 
% simpleDeltas: 
% vector of perturbations-
%
%         * simpleDeltas format: 
%         * fc = fiducial collection, s = source, d = detector, sdp = source detector pair
%         * [TranslationFromSource(d1),
%         * RotationPolar(d1),
%         * RotationAzimuthal(d1),...
%         * 
%         * TranslationFromSource(di) for 1<i<=n
%         * RotationPolar(di),  
%         * RotationAzimuthal(di),
%         * RotationNormal(di), 
%         * XTranslation(sdpi)
%         * YTranslation(sdpi) 
%         * ZTranslation(sdpi) 
%         * RotationPolar(sdpi)
%         * RotationAzimuthal(sdpi)....
%         * 
%         * TranslationFromSource(dn),
%         * RotationPolar(dn),  
%         * RotationAzimuthal(dn),
%         * RotationNormal(dn), 
%         * XTranslation(sdpn)
%         * YTranslation(sdpn) 
%         * ZTranslation(sdpn) 
%         * RotationPolar(sdpn)
%         * RotationAzimuthal(sdpn)....
%         * 
%         * XTranslation1(fc), 
%         * YTranslation2(fc),
%         * ZTranslation3(fc),
%         * Rotation1(fc), 
%         * Rotation2(fc),
%         * Rotation3(fc)],
%         */
%
% paramDeltaStruct: self describing struct which has the following fields- see thesis for pictures of what these params mean.  
% 
% paramDeltaStruct.detiTranslationFromSource 
% paramDeltaStruct.detiPolarAngle 
% paramDeltaStruct.detiAzimuthalAngle   
% paramDeltaStruct.detiNormalAngle (for i>1) 
% paramDeltaStruct.sdpiXTranslation (for i>1)
% paramDeltaStruct.sdpiYTranslation (for i>1)
% paramDeltaStruct.sdpiZTranslation (for i>1)
% paramDeltaStruct.sdpiPolarRotation (for i>1)  
% paramDeltaStruct.sdpiAzimuthalRotation (for i>1)  
% paramDeltaStruct.fiducialCollection.xTranslation
% paramDeltaStruct.fiducialCollection.yTranslation
% paramDeltaStruct.fiducialCollection.zTranslation: 0
% paramDeltaStruct.fiducialCollection.rot1:
% paramDeltaStruct.fiducialCollection.rot2
% paramDeltaStruct.fiducialCollection.rot3


firstOffset = 3;
secondOffset = firstOffset + (system.getNumberOfSDP() - 1) * 9;
thirdOffset = secondOffset + 6;

det0 =  system.getSDP(0).getDetector();
simpleDeltas(1,1) = det0.getTranslation3();
simpleDeltas(2,1) = det0.getRotation1();
simpleDeltas(3,1) = det0.getRotation2();

paramDeltaStruct.(['det1','TranslationFromSource']) = simpleDeltas(1);
paramDeltaStruct.(['det1','PolarAngle'])          = recenter(simpleDeltas(2));
paramDeltaStruct.(['det1','AzimuthalAngle'])      = recenter(simpleDeltas(3));

for i =2:system.getNumberOfSDP()
    sdpi = system.getSDP(i-1); %%java indexing - 1
    deti = sdpi.getDetector();
    detstr = ['det',num2str(i)];
    sdpstr = ['sdp',num2str(i)];
    
    simpleDeltas(firstOffset + (i-2)*9 + 1,1) = deti.getNormalTranslation();
    paramDeltaStruct.([detstr,'TranslationFromSource']) = deti.getTranslation3();
    
    simpleDeltas(firstOffset + (i-2)*9 + 2,1) = system.getDetectorPolarAngle(i-1);
    paramDeltaStruct.([detstr,'PolarAngle']) = recenter(system.getDetectorPolarAngle(i-1));
    
    simpleDeltas(firstOffset + (i-2)*9 + 3,1) = system.getDetectorAzimuthalAngle(i-1);
    paramDeltaStruct.([detstr,'AzimuthalAngle']) = recenter(system.getDetectorAzimuthalAngle(i-1));
    
    simpleDeltas(firstOffset + (i-2)*9 + 4,1) = system.getDetectorNormalAngle(i-1);
    paramDeltaStruct.([detstr,'NormalAngle']) = recenter(system.getDetectorNormalAngle(i-1));
    
    simpleDeltas(firstOffset + (i-2)*9 + 5,1) = sdpi.getTranslation1();
    paramDeltaStruct.([sdpstr,'XTranslation']) = sdpi.getTranslation1();
    
    simpleDeltas(firstOffset + (i-2)*9 + 6,1) = sdpi.getTranslation2();
    paramDeltaStruct.([sdpstr,'YTranslation']) = sdpi.getTranslation2();
    
    simpleDeltas(firstOffset + (i-2)*9 + 7,1) = sdpi.getTranslation3();
    paramDeltaStruct.([sdpstr,'ZTranslation']) = sdpi.getTranslation3();
    
    simpleDeltas(firstOffset + (i-2)*9 + 8,1) = sdpi.getRotation1();
    paramDeltaStruct.([sdpstr,'PolarRotation']) = recenter(sdpi.getRotation1());
    
    simpleDeltas(firstOffset + (i-2)*9 + 9,1) = sdpi.getRotation3();
    paramDeltaStruct.([sdpstr,'AzimuthalRotation']) = recenter(sdpi.getRotation3());
end

simpleDeltas(secondOffset + 1,1) = system.getFCT1();
paramDeltaStruct.fiducialCollection.xTranslation = system.getFCT1();

simpleDeltas(secondOffset + 2,1) = system.getFCT2();
paramDeltaStruct.fiducialCollection.yTranslation = system.getFCT2();

simpleDeltas(secondOffset + 3,1) = system.getFCT3();
paramDeltaStruct.fiducialCollection.zTranslation = system.getFCT3();

simpleDeltas(secondOffset + 4,1) = system.getFCR1();
paramDeltaStruct.fiducialCollection.rot1 = recenter(system.getFCR1());

simpleDeltas(secondOffset + 5,1) = system.getFCR2();
paramDeltaStruct.fiducialCollection.rot2 = recenter(system.getFCR2());

simpleDeltas(secondOffset + 6,1) = system.getFCR3();
paramDeltaStruct.fiducialCollection.rot3 = recenter(system.getFCR3());

%%paramDeltaStruct.simpleDeltas = simpleDeltas;
end

    
    
%%rewrites angles to all be between -180 and 180
function [newAngle] = recenter(oldAngle)
    newAngle = oldAngle;
    if (newAngle<-180)
        while (newAngle<-180)
            newAngle = newAngle+360;
        end
    end
    if (newAngle>180)
        while (newAngle>180)
            newAngle = newAngle-360;
        end
    end
end

    
    