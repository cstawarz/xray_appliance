function [center] = xrg_getSourceCenter(expectedSystem, sourceIndex)
%% xrg_getSourceCenter: gets center of a source within xray system
%%
%%%%%%%%%%%%%%%%%%%%%%%
%
% [center] = xrg_getSourceCenter(expectedSystem, sourceIndex)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%
% expectedSystem: xraySystem
% sourceIndex: the index of the source whose center location we want to
% know
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs:
%
% center:  [x,y,z] describing the center of the sourceIndxth source in
% the expected system.
%
%

    centerj = expectedSystem.getSourceLocation(sourceIndex - 1); %% -1 because of java indexing
    center(1) = centerj.x;
    center(2) = centerj.y;
    center(3) = centerj.z;
end