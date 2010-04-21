%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% xrg_resetToRandomFiducials
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% [] =xrg_ resetToRandomFiducials(...
%%    system,...
%%   fiducials,...
%%    fiducialDelta)
%%
%% system: XRAY system
%% fiducial: number of fiducials we want to have in the system.
%% fiducialDelta: approximate distance between the reference frame forming
%% 3 fiducials
%%
%% Given an xray System, clears it of any fiducials contained within,
%% and adds semi-random fiducials.
%%
%% The fiducials are layed out as follows: the 0th fiducial is placed randomly
%% within a box centered at (0,0,0) with length 2*fiducialDelta.
%% The first fiducial is also placed randomly within this box.
%% The second fiducial is placed within the box, at a distance of
%% between fiducialDelta to (Fiducial Delta + 1000) (magic number,
%% change this) to the first fiducial. The Third fiducial is placed within
%% the box, and within fiducial delta to (fiducial delta +1000) of both the first
%% fiducial and the second fiducial. Any additional fiducials are placed
%% randomly within the box.
%%
%% modifies system
function [] = xrg_resetToRandomFiducials(...
    system,...
    fiducials,...
    fiducialDelta)

system.emptyFids();
for i = 1:fiducials
    system.addDefaultLightFiducial(0,0,0)
end
for i=1:fiducials

    %%extraFiducialCase
    if (i>4)
        system.setLightFiducialPosition(randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            i-1);
    end

    %%electrode case
    if (i == 1)
        system.setLightFiducialPosition(randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            i-1);
    end

    %%fid 1 case
    if (i == 2)
        system.setLightFiducialPosition(randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            randCenteredAtZero2(fiducialDelta,1,1),...
            i-1);
    end

    %%fiducial 2 case
    if (i == 3)
        d12 = 0;
        while (d12<fiducialDelta)||(d12>fiducialDelta+1000)
            system.setLightFiducialPosition(randCenteredAtZero2(fiducialDelta,1,1),...
                randCenteredAtZero2(fiducialDelta,1,1),...
                randCenteredAtZero2(fiducialDelta,1,1),...
                2);
            d12 = system.getFiducialLocation(1).distance(system.getFiducialLocation(2));
        end
        %d12
    end

    %%fiducial 3 case
    if (i == 4)
        d13 = 0;
        d23 = 0;
        while ((d13<fiducialDelta)||(d13>fiducialDelta+1000)||(d23<fiducialDelta)||(d23>fiducialDelta+1000))
            system.setLightFiducialPosition(randCenteredAtZero2(fiducialDelta,1,1),...
                randCenteredAtZero2(fiducialDelta,1,1),...
                randCenteredAtZero2(fiducialDelta,1,1),...
                i-1);
            d13 = system.getFiducialLocation(1).distance(system.getFiducialLocation(3));
            d23 = system.getFiducialLocation(2).distance(system.getFiducialLocation(3));
        end
    end
end

