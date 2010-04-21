clear all
for i = 1:20
    
    MRILocalizationError = .5;
    xrayLocalizationError = .1;
    electrodeLocalizationError = .5;
    machiningError = .05;
    
    Machined2XRAYtransformation = 720*rand(6,1)-360;
    Machined2XRAYtransformation(4) = mri_recenter(Machined2XRAYtransformation(4));
    Machined2XRAYtransformation(5) = mri_recenter(Machined2XRAYtransformation(5));
    Machined2XRAYtransformation(6) = mri_recenter(Machined2XRAYtransformation(6));
        
    Machined2MRItransformation = 720*rand(6,1)-360;
    Machined2MRItransformation(4) = mri_recenter(Machined2MRItransformation(4));
    Machined2MRItransformation(5) = mri_recenter(Machined2MRItransformation(5));
    Machined2MRItransformation(6) = mri_recenter(Machined2MRItransformation(6));

    
    
     brassBeads_Machined = ...
        [0,6,0;...
         6,0,0;...
         20,0,0;...
         20,14,0;...
         0,20,0;...
         14,20,0];
     
    noisyBrassBeads_Machined = brassBeads_Machined + ...
        2*machiningError * rand(size(brassBeads_Machined,1),size(brassBeads_Machined,2)) - machiningError;
         
        
    vitaminE_Machined = ...
        [0,0,0;
         0,20,0;
         20,0,0;
         20,20,0;
         6,20,0;
         20,6,0];
     
    noisyVitaminE_Machined = vitaminE_Machined + ...
        2*machiningError * rand(size(vitaminE_Machined,1),size(vitaminE_Machined,2)) - machiningError;
    
    electrode_Machined = [10,10,20];
   
    
    
   brassBeads_MRI = mri_applyRigidTransform(Machined2MRItransformation, brassBeads_Machined);
   noisyBrassBeads_MRI = brassBeads_MRI + ...
   randCenteredAtZero2(MRILocalizationError,...
                       size(brassBeads_MRI,1),...
                       size(brassBeads_MRI,2));
                       

   vitaminE_MRI = mri_applyRigidTransform(Machined2MRItransformation, vitaminE_Machined);
   noisyVitaminE_MRI = vitaminE_MRI + ...
   randCenteredAtZero2(MRILocalizationError,...
                       size(vitaminE_MRI,1),...
                       size(vitaminE_MRI,2));...
                                        
                       
   brassBeads_XRAY = mri_applyRigidTransform(Machined2XRAYtransformation, brassBeads_Machined);
   noisyBrassBeads_XRAY = brassBeads_XRAY + ...
   randCenteredAtZero2(xrayLocalizationError,...
                       size(brassBeads_XRAY,1),...
                       size(brassBeads_XRAY,2));
                   
                   
   electrode_XRAY = mri_applyRigidTransform(Machined2XRAYtransformation, electrode_Machined);
   
   electrodeNoise = randCenteredAtZero2(electrodeLocalizationError, size(electrode_XRAY, 1), size(electrode_XRAY,2));
   nrms(i) = norm(electrodeNoise);
   noisyElectrode_XRAY = electrode_XRAY + electrodeNoise;
   
                    
%    electrode_XRAY, brassBeads_XRAY, brassBeads_MRI
% brassBeads_MRI, Machined2MRItransformation

   [electrode_MRI] = mri_electrode2MRIFrame(vitaminE_Machined,...
                                            vitaminE_MRI,...
                                            brassBeads_Machined,...
                                            brassBeads_XRAY,...
                                            electrode_XRAY);
%                                         
   [noisyElectrode_MRI] = mri_electrode2MRIFrame(noisyVitaminE_Machined,...
                                            noisyVitaminE_MRI,...
                                            noisyBrassBeads_Machined,...
                                            noisyBrassBeads_XRAY,...
                                            noisyElectrode_XRAY);
                                            i
                                             err(i) = norm(electrode_MRI - noisyElectrode_MRI);
    
end


    
