function [RHSPermuted, expectedCalibratedSystem, centerPoints, resnorm, iters, exitflag] =...
    recon_reconstructIgnoreCorrespondences(expectedCalibratedSystem, RHS)


%% recon_reconstructIgnoreCorrespondences: incorrect correspondence reconstruction
%
% [RHSPermuted, expectedCalibratedSystem, centerPoints, resnorm, iters, exitflag] =...
%     recon_reconstructIgnoreCorrespondences(expectedCalibratedSystem, RHS)
% 
% We may be unable to determine the correspondences between images on two detectors. 
% If it is believed that the correspondences are somehow incorrect within RHS, 
% we can check every permutation of correspondences, by changing the order of the detector1 feature points. 
% To perform reconstruction in the absence of knowledge about the
% correspondences, call recon_reconstructIgnoreCorrrespondences. Note that
% this is only for 2 detector systems. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
% expectedCalibratedSystem  is our assumed system after calibration.
%
% RHS is a vector of extracted features from images of the fiducials (or a struct of extracted features, 
% see readme.doc). 
% The correspondences of extracted feature points may be incorrect. 
% The order of the detector2 feature points in RHS determines the order of
% reconstructed centers.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Output:
%
% RHSPermuted: the permutation of RHS that allows reconstruction with the lowest resnorm.
% The permuted part of RHS is those values that are detector1 values;
% detector2 values are held fixed in place. See RHS format in documentation
% for details about which elements are the detector2 
% 
% expectedCalibratedSystem: the system after reconstruction- 
% it will have reconstructed fiducials in it, rather than the calibration object.
%
% centerPoints: n*3 array of the reconstructed 3d centers of the fiducials we have imaged (or electrode),
% ordered in the same order as the RHS that was passed in (see RHS format within feature extraction)
%
% resnorm: the norm of the residual of the best reconstruction- 
% this can give some idea of how good our reconstruction is- it should be small.
%
% ExitFlag indicates whether the best reconstruction converged. If it didn’t we have a very bad reconstruction.
%
% Iters is how many iterations the best reconstruction took.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires: 
% 2 detector system!!!!! only works for two detector system
% 
% expectedCalibrated system has as many detectors as there were
% in the system that formed the RHS
%
% Modifies: 
% expectedCalibratedSystem to have fiducial layout corresponding to
% reconstruction. Removes any calibration object or other fiducials
% already in expectedCalibratedSystem.
%
%
%


%%checking whether input is nested struct format, struct or vector format. If struct or nested struct,
%convert to vector form
RHS = xrg_RHSVerbose2Vector(RHS.RHS_Verbose);


RHSPart2 = RHS(length(RHS)/2+1:length(RHS),1);


% permuting over every RHS combination to find miniimum one

for i = 0:2:length(RHS)/2-2
   
    a(1) = RHS(i+1);
    a(2) = RHS(i+2);
    RHSPart1{(i/2)+1} = a;

end

ps = perms(RHSPart1);


residue = 1000000000;
for i=1:size(ps,1)
    RHSNew = [];
    perm = ps(i,:)
    for j = 1:size(perm,2)
        perm2 = perm{j};
        
        col = perm2(1);
        row = perm2(2);
        
        RHSNew = [RHSNew; col];
        RHSNew = [RHSNew; row];
    end
    RHSNew = [RHSNew; RHSPart2];
    
   [expectedCalibratedSystema, centerPointsa, resnorma, itersa, exitflaga] = recon_reconstruct(expectedCalibratedSystem, RHSNew); %  

    if (resnorma<residue)
        [expectedCalibratedSystem, centerPoints, resnorm, iters, exitflag] = recon_reconstruct(expectedCalibratedSystem, RHSNew);
        RHSPermuted = RHSNew;
        residue = resnorma
    end
end
