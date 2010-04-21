function[] = xrg_showRHS(RHS_Verbose, detectorIndex, pointIcon, showNumbers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [xrg_showRHS(RHS_Verbose, detectorIndex, pointIcon, showNumbers)
% 
% Use this function to display the feature points of an RHS, overlaying the
% image form which feature points were extracted if such an image exists.
% Works for an n detector system.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% RHS_Verbose: the struct saved by detIm_formRHSVerbose, or the struct
% returned by xrg_getRHS. This struct contains feature extraction data.
% The RHS_Verbose struct must have fields of the form:
%
% RHS_Verbose.detectori.fiducialjProjection.x
% RHS_Verbose.detectori.fiducialjProjection.y
%
% detectorIndex: the detector from which we want to visualize feature
% points.
% 
% pointIcon: the string type of point we want plotted: i.e., 'r*', 'o-', etc
%
% showNumbers: boolean indicating whether we want the feature points
% numbered according to the order in which they were selected
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:
%
% A plot showing the original detector image(if it exists in the
% RHS_Verbose) overlayed with the extracted feature points plotted
% according to pointIcon. The feature points are nubmered if showNumbers =1;
%
% 

args = nargin;
if(args==2)
    pointIcon = 'r*'
    showNumbers = 1;
end
if(args==3)
    showNumbers = 1;
end

if(isfield(RHS_Verbose,'RHS_Verbose')) %%checking if it is a nested struct
    RHS_Verbose = RHS_Verbose.RHS_Verbose;
end

imagestr = ['detector', num2str(detectorIndex), 'Projection']; %%chekcing if the RHS has an image file
%%case where we have actual extracted features- the is a real RHS
if(isfield(RHS_Verbose, imagestr))
    a = RHS_Verbose.(imagestr);
    imshow(uint8(a));
%%simulated RHS- make sure we view from same angle as a real image so that
%%projection points look good
else
%   set(gca, 'view', [0,-90]); 
%     detectorStruct = RHS_Verbose.(['detector', num2str(detectorIndex)]);
%     rows = detectorStruct.detectorRows;
%     cols = detectorStruct.detectorCols;
%     imshow(uint8(zeros(rows,cols)));
end

hold on;


%%counting how many fiducials first
fiducialString = 'fiducial1Projection';
fiducialIndex = 1;

if(isfield(RHS_Verbose, 'numFids'))
   numFids = RHS_Verbose.numFids;
else   
   if(~isfield(RHS_Verbose.detector1, fiducialString))
       error('no fiducials in the RHS_Verbose- it is malformatted')
   end

   numFiducials = 0;
   fiducialIndex = 1;
   while(isfield(RHS_Verbose.detector1, fiducialString))
       numFids = fiducialIndex;
       fiducialIndex = fiducialIndex + 1;
       fiducialString = ['fiducial', num2str(fiducialIndex),'Projection'];
   end
end



fiducialIndex = 1;
detectorString = ['detector', num2str(detectorIndex)];
fiducialString = ['fiducial', num2str(fiducialIndex), 'Projection'];
%%looping over every fiducial in the struct for that particular detector

for fiducialIndex = 1:numFids
    x = RHS_Verbose.(detectorString).(fiducialString).x+1; %% +1 to convert to matlab coords
    y = RHS_Verbose.(detectorString).(fiducialString).y+1;
    plot(x,y, pointIcon); 
    if (showNumbers)
        text(x,y, ['  ',num2str(fiducialIndex)])
    end
    %%incrementing the fiducial index before next loop
    fiducialIndex = fiducialIndex + 1;
    fiducialString = ['fiducial', num2str(fiducialIndex), 'Projection'];
end    

axis on;

hold off
