function [RHS] = xrg_RHSVerbose2Vector(RHS_Verbose)
%%RHSVerbose2Vector: converts the verbose struct to a vector form suitable for a numerical method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [vector] = xrg_RHSVerbose2Vector(RHS_Verbose) 
%
% Method used to convert RHS_Verbose to RHS format (see readme.doc)
%
%
% Inputs: 
% RHS_Verbose: struct form of RHS
%
% Outputs: 
% vector: vector form of RHS
%
% NOTE: this ahs only been tested for a 2 detector system 


%%checking whether input is nested struct format, struct or vector format. If struct or nested struct,
%%rewriting as vector
if(~isa(RHS_Verbose, 'struct'))
    RHS = RHS_Verbose; %%if its not a struct do nothing
elseif(isfield(RHS_Verbose, 'RHS_Verbose')) %%nested struct format
    RHS = xrg_RHSVerbose2Vector(RHS_Verbose.RHS_Verbose);
else %%%struct format

    detectorString = 'detector1';
    detectorIndex = 1;

    %%geting the number of detectors
    if(isfield(RHS_Verbose, 'numDetectors'))
        numDetectors = RHS_Verbose.numDetectors;
    else
        if(~isfield(RHS_Verbose, detectorString))
            %         detectorString
            %        RHS.(detectorString)
            error('no detectors in the RHS_Verbose- it is malformatted')
        end

        numDetectors = 0;
        detectorIndex = 1;
        while(isfield(RHS_Verbose, detectorString))
            numDetectors = detectorIndex;
            detectorIndex = detectorIndex + 1;
            detectorString = ['detector', num2str(detectorIndex)];
        end
    end

    fiducialString = 'fiducial1Projection';
    fiducialIndex = 1;

    if(isfield(RHS_Verbose, 'numFids'))
        numFids = RHS_Verbose.numFids;
    else
        if(~isfield(RHS_Verbose.detector1, fiducialString))
            error('no fiducials in the RHS_Verbose- it is malformatted')
            fiducialString
        end

        numFids = 0;
        fiducialIndex = 1;
        while(isfield(RHS_Verbose.detector1, fiducialString))
            numFids = fiducialIndex;
            fiducialIndex = fiducialIndex + 1;
            fiducialString = ['fiducial', num2str(fiducialIndex),'Projection'];
        end
    end

    % numDetectors
    % numFids
    %

    fiducialString = 'fiducial1Projection';
    fiducialIndex = 1;
    RHS = [];
    %%looping over every fiducial in the struct for every detector
    for detectorIndex=1:numDetectors
        detectorString = ['detector', num2str(detectorIndex)];
        for fiducialIndex=1:numFids
            fiducialString = ['fiducial', num2str(fiducialIndex), 'Projection'];
            RHS = [RHS; RHS_Verbose.(detectorString).(fiducialString).x];
            RHS = [RHS; RHS_Verbose.(detectorString).(fiducialString).y];
        end
    end
end
