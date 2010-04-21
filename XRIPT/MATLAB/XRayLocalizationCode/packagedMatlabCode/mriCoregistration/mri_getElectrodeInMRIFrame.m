function[electrode_MRIFrame] = mri_getelectrodeInMRIFrame(oilBeads_MachinedFrame,...
                                                    oilBeads_MRIFrame,...
                                                    brassBeads_MachinedFrame,...
                                                    brassBeads_XRayFrame,...
                                                    electrode_XRayFrame)
                                                
%% mri_getElectrode_MRIFrame: Use to get electrode position in mri frame given xray data and prior on the frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs: 
%
% oilBeads_MachinedFrame: the coordinates of the centers of the vitamin e beads
% according to the machined specification. n*3 array 
%
% oilBeads_MRIFrame: the coordinates of the centers of the vitamin e beads
% in the mri frame. n*3 array
%
% brassBeads_MachinedFrame: the coordinates of the centers of the brass beads
% according to the machined specification. m*3 array
%
% brassBeads_XRayFrame: the coordinates of the centers of the brass beads
% in the xray frame. m*3 array
%
% electrode_MRIFrame: the coordinates of the electrode tip
% in the mri frame. 1*3 array
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs 
%
% electrode_MRIFrame: the coordinate of the electrode in the MRI frame
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% requires: 
%
% The correspondences implicit in the ordering of the same set of points in
% two different frames must be correct. 
%
%
%%%%%%%%%%%%%%%%%%%%%%%
% Overall goal
%
%     In order to get coordinates of the electrode in the mri frame, we need to
%     figure out the transformation from the XRAY frame to the mri frame. To
%     figure out this transformation, we need to know the coordinates of some
%     set of points in both the xray frame and the mri frame.
%
%     We will use the coordinates of the brass beads in the xray frame and mri
%     frame to get the Xray->MRI transformation. The coordinates of the brass beads 
%     in the xray frame are known, but they are not known in the mri frame.
%     Thus to solve the overall goal, we need to solve the Subgoal:
%     find the coordinates of the brass beads in the mri frame.
%
% Subgoal
%
%     We have the coordinates of vitamin e beads in both the machined frame
%     and in the mri_frame, so the machined frame->mri_frame transformation is known.
%     We apply this transformation to the brass bead points coordinates in
%     the machinedFrame (we know these coordinates because they have been
%     machined as we specify them, or because we have CT'd the entire
%     reference frame) and get the resulting brass bead coordinates in the
%     mri_frame. 
%
%
% Once we have achieved the subgoal of finding the brass beads coordinates
% in the MRI frame and xray frame, the XRAY->MRI transfromation is
% specified. We apply this transformation to the electrode point coordinates in XRAY frame
% and get the electrode point coordinates in the mri_frame
%


%%accomplishing the subgoal
%first we get the coordinates of the brass beads in the mri frame 
[brassBeads_MRIFrame, transformation] =...
    mri_target2DestFrameTransform(brassBeads_MachinedFrame, oilBeads_MachinedFrame, oilBeads_MRIFrame);

%%now that we have accomplished the subgoal, we can use the known
%%coordinates of brass beads in xray frame and in mri frame to convert the
%%electrode point xray frame coordinates to mri frame coordinates.

% electrode_XRayFrame, brassBeads_XRayFrame, brassBeads_MRIFrame
% pause
electrode_MRIFrame = mri_target2DestFrameTransform(electrode_XRayFrame, brassBeads_XRayFrame, brassBeads_MRIFrame); 

                                                    