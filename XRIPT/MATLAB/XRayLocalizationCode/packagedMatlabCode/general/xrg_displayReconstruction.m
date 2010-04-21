function[] = xrg_displayReconstruction(system, RHS_Verbose)

%%xrg_displayReconstruction: display how good recontruction did for n detector system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [] = xrg_displayReconstruction(system, RHSVerbose)
% 
% Use this function to display the extracted feature points next to the
% predicted feature points folowing reconstruction to get an idea of how
% well reconstruction has matched actual projection to expected
% projections.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% System: an xray system follwing reconstruction
% 
% RHS_Verbose: the verbose form of RHS that was passed into reconstruction or calibration. 
% This can either be an actual RHS_Verbose as created by feature extraction
% from a real image, or a simulated RHS_Verbose as created by xrg_getRHS
% called on a simulated XRay system. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:
%
% A plot showing the original detector images(if they exists in the
% RHS_Verbose) overlayed with the extracted feature points in red, and the
% the expected feature points as given by reconstruction or calibration in blue
%
% 
%

if(isfield(RHS_Verbose,'RHS_Verbose')) %%checking if it is a nested struct
    RHS_Verbose = RHS_Verbose.RHS_Verbose;
end
    
detectors = system.getNumberOfSDP();

hold off
for i=1:detectors
    subplot(1,detectors,i)
    showNumbers = 1;
    xrg_showRHS(RHS_Verbose,i, 'b*', showNumbers); %%shows the extracted RHS on top of the calibrated image from which it was extracted
    showNumbers = 0;
    xrg_showRHS(xrg_getRHS(system), i, 'r*', showNumbers); %%shows the RHS as given by expected projections after reconstruction
    detStr = ['D',num2str(i)]; 
    title([detStr, '.  Red = RHS from feature extraction, Blue = expected RHS from recon/calib'])
end