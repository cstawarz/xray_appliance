function FrameTransformer()


% random fiducials for testing
loc1 = getRandomLocation;
loc2 = getRandomLocation;
loc3 = getRandomLocation;
loc4 = getRandomLocation;
loc5 = getRandomLocation;
delta = getRandomLocation;


%% =================================================
%% frame registrations =============================

initGlobalFrames;

%% build a frame and all its elements (this should be a gui)
[frame] = makeNewFrame('xsh','xray head stable frame');
[frame,err] = addElementToFrame(frame,'alex_f1',loc1,'x');
[frame,err] = addElementToFrame(frame,'alex_f2',loc2,'x');
[frame,err] = addElementToFrame(frame,'alex_f3',loc3,'x');
[frame,err] = addElementToFrame(frame,'alex_f4',loc4,'x');
[frame,err] = addElementToFrame(frame,'alex_f5',loc5,'x');
addFrameToGlobalRegistry(frame);



% %% build a frame and all its elements (this should be a gui)
% [frame] = makeNewFrame('p','plastic frame');
% [frame,err] = addElementToFrame(frame,'alex_f1',xx,'x');
% [frame,err] = addElementToFrame(frame,'alex_f2',xx,'x');
% [frame,err] = addElementToFrame(frame,'alex_f3',xx,'x');
% [frame,err] = addElementToFrame(frame,'alex_f4',xx,'x');
% [frame,err] = addElementToFrame(frame,'alex_f5',xx,'x');
% [frame,err] = addElementToFrame(frame,'alex_m1',xx,'m');
% [frame,err] = addElementToFrame(frame,'alex_m2',xx,'m');
% [frame,err] = addElementToFrame(frame,'alex_m3',xx,'m');
% [frame,err] = addElementToFrame(frame,'alex_m4',xx,'m');
% addFrameToGlobalRegistry(frame);
% 
% 
% %% build another frame and all its elements (this should be a gui)
% [frame] = makeNewFrame('m','anatomical mri frame');
% [frame] = addElementToFrame(frame,'alex_m1',xx,'m');
% [frame] = addElementToFrame(frame,'alex_m2',xx,'m');
% [frame] = addElementToFrame(frame,'alex_m3',xx,'m');
% [frame] = addElementToFrame(frame,'alex_m4',xx,'m');
% addFrameToGlobalRegistry(frame); 
% 

%% here is the frame we collect with each shot
%% build another frame and all its elements (this should be a gui)
[frame] = makeNewFrame('xs','xray system frame');
[frame] = addElementToFrame(frame,'alex_f1',loc1+delta,'x');
[frame] = addElementToFrame(frame,'alex_f3',loc3+delta,'x');
[frame] = addElementToFrame(frame,'alex_f4',loc4+delta,'x');
addFrameToGlobalRegistry(frame);

%% now, all frames are registered
%% =================================================



%% =================================================
%% build transforms between frames that you want to go between
initGlobalFrameTransforms;

[frameTransform, err] = findRigidTransform('xs','xsh')
if (err == 0) addFrameTransformToGlobalRegistry(frameTransform); end;
clear frameTransform;

%[frameTransform, err] = findRigidTransform('xsh','p');
%if (err == 0) addFrameTransformToGlobalRegistry(frameTransform); end;
%clear frameTransform;

%[frameTransform, err] = findRigidTransform('p','m');
%if (err == 0) addFrameTransformToGlobalRegistry(frameTransform); end;
%clear frameTransform;

%% now all requested transforms are built and registered
%% =================================================

%% =================================================
%% save all data in proper directory associated with xray package.

%% TODO


%% =================================================
% now it is trivial to project from one frame to another
e_xs{1}.location_um = [3 3 3];      % e.g. electrode in 'xs' frame.
[e_xsh,err] = projectPointsToNewFrame(e_xs,'xs','xsh')
e_xsh{1}.location_um
[e_p,err] = projectPointsToNewFrame(e_xsh,'xsh','p');
[e_mri,err] = projectPointsToNewFrame(e_p,'p','m');

%% save results in proper directory

%% =================================================





% 
% 
% %% main code here
% 
% figure(1);
% clf;
% 
% H1 = subplot('position',[0.05 0.55 0.4 0.4]);
% H2 = subplot('position',[0.55 0.55 0.4 0.4]);
% H3 = subplot('position',[0.55 0.1 0.4 0.4]);
% 
% %% check that all in same frame and plot
% 
% plotInFrame(H1,f,'r');
% 
% plotInFrame(H2,g,'b');
% 


end
% =========================================================================
% END OF MAIN



% =========================================================================
function [loc] = getRandomLocation() 
    loc = (rand(1,3)*5000) + 10000;
    return;
end



%% plotting

function plotInFrame(H,f,col);

    if (length(col)==1)
        co(1:length(f)) = col;
    else
        if (length(col) ~= length(f))
            return;
        end;
        co = col;
    end

    if (~checkAllSameFrame(f)) return; end;

    for k = 1:length(f); 
        x(k) = f{k}.location_um(1)/1000;
        y(k) = f{k}.location_um(2)/1000;
        z(k) = f{k}.location_um(3)/1000;
    end

    ma(1) = max(x);
    mi(1) = min(x);
    ma(2) = max(y);
    mi(2) = min(y);
    ma(3) = max(z);
    mi(3) = min(z);
    for i=1:3
        d(i) = (ma(i)-mi(i))*0.1;
    end

    subplot(H); 
    for k = 1:length(f);
        plot3(x(k),y(k),z(k),[co(k) 'o']);hold on;
        plot3([x(k) x(k)] ,[ y(k) y(k)] , [z(k) mi(3)-d(3)],'k-');
    end
    grid;
    axis([mi(1)-d(1), ma(1)+d(1), mi(2)-d(2), ma(2)+d(2), mi(3)-d(3), ma(3)+d(3) ]);

    return;

end








