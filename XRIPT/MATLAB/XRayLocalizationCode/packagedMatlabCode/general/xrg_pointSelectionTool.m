function [points, fh] = xrg_pointSelectionTool(imageArray, saveFigure)

%% xrg_pointSelectionTool: tool for selecting points in an image
%%
%%%%%%%%%%%%%%%%%%%%
%%
%%  [points, fh] = xrg_pointSelectionTool(imageArray, saveFigure)
%%
%% given an image, allows the user to select points in the image, and
%% numbers them on the display of the image. if saveFigure = 1, 
%% User can save the figure for future reference.
%%             
%%                         points is in format:
%%
%%                           [SelectedPoint1.x, firstSelectedPoint1.y;
%%                            SelectedPoint2.x, firstSelectedPoint2.y;...
%%                            SelectedPointn.x, firstSelectedPointn.y]
%%
%% fh is the figure handle of the point selection tool window
%%
%% Press right click when done selecting points
%%
%% Note: you cannot zoom in on the image while using the
%% xrg_pointSelectTool

fh = imshow(imageArray);
title('Choose points in desired order with left button,  press right button when done')
axis on;
hold on;
xy = [];
n = 0;


disp('Left mouse button picks points.')
disp('Click Right mouse button when done')
% disp('Right mouse button picks last point, or push enter button.')
but = 1;
ent = 0;

%%setting font 
%%set(text, 'FontSize', fontsize);
units = get(gca,'defaulttextunits');
set(gca,'defaulttextunits','data')

% Loop, picking up the points while enter hasnt been pressed and button =
% left
while ((but == 1)&(ent==0))
    xi = [];
    yi = [];
    [xi,yi,but] = ginput(1);
    if (size(xi,1)~=0)
        if (but == 1)
            set(text, 'color', 'blue');
            %%plot(xi,yi,'r.')
            n = n+1;
            ht = text(xi,yi,num2str(n));
            xy(n,:) = [xi;yi];
            %%h = [ht; h];
        else
        end
    else 
        %%updating for enter case- case in which no button was clicked so
        %%xi is uninitialized
        ent = 1;
    end
end
hold off

%%saving the figure
if (saveFigure)
    [filename, pathname] = uiputfile('*.fig', 'save the point selection figure');
    saveas(fh, strcat(pathname, filename), 'fig');
end
points = xy;
fh;