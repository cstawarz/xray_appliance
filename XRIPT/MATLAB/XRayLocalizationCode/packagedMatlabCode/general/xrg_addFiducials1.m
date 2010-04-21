function [] = xrg_addFiducials1(system, numberOfFiducials)
%% xrg_addFiducials1: use to add n Fiducials at the origin
%%
%%%%%%%%%%%%%%%%%%%
%
% [] = xrg_addFiducials1(system, numberOfFiducials)
%
% adds numberOfFiducials fiducials to the xray system, all at an initial location of 
% (0,0,0)
%
% called by addFiducials 
for i=1:numberOfFiducials
        system.addDefaultLightFiducial(0,0,0);
    end
end
