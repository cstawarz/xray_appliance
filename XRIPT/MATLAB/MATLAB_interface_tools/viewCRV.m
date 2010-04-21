function viewCRV(anat_crv, point, FFOR_name, funct_crv, functional_opacity)



if(nargin < 3)
    fprintf(2, 'error using viewCRV:  viewCRV(anat_crv_path, point, FFOR_name, [funct_crv_path], [functional_opacity])\n');
    return;
end


anat_xforms = anat_crv.transforms;

if(nargin >= 4)
    funct_xforms = funct_crv.transforms;
    funct_vol = funct_crv.img;
    if(nargin == 4)
        functional_opacity = 0.5;
    end
else
    funct_xforms = anat_xforms;
    funct_vol = zeros(size(anat_crv.img));
end


xform = [];

for ii=1:length(anat_xforms)
    if(strcmp(anat_xforms{ii}.name, FFOR_name))
        for jj=1:length(funct_xforms)
            if(strcmp(funct_xforms{jj}.name, FFOR_name))
                xform = anat_xforms{ii}.transfromFromFFORToNativeVolume;
            end
        end
    end
end

if(size(xform) > 0)
    point2Xform = [point 1]';
    newPoint = xform*point2Xform;
    newPoint = newPoint(1:3)';
else
    fprintf(2, 'anatomical and functional CRVs do not have matching FFORs\n');
    return;
end

% first scale the volume from 0.1:
anat_vol_scaled = anat_crv.img ./ max(anat_crv.img(:));
abs_funct = abs(funct_vol);

% find the maximum absolute functional value
abs_max_functional = max(abs_funct(:));
funct_scaled = (funct_vol ./ (2*abs_max_functional)) + 0.5;

% % get the positive values of the functional
% pos_funct_volume = (funct_vol > 0) .* funct_vol;
% toc
% tic
% if(max_functional == 0)
%     pos_funct_scaled = pos_funct_volume;
% else
%     pos_funct_scaled = pos_funct_volume ./ max_functional;
% end
% toc
% tic
% 
% % get the positive values of the functional
% neg_funct_volume = -1*((funct_vol < 0) .* funct_vol);
% toc
% tic
% if(max_functional == 0)
%     neg_funct_scaled = neg_funct_volume;
% else
%     neg_funct_scaled = neg_funct_volume ./ max_functional;
% end
% toc


horizontal_slice = overlayFunctionalData(anat_vol_scaled, funct_scaled, 'horizontal', newPoint(3), functional_opacity);
figure;
image(horizontal_slice);
axis image;
title(['Horizontal slice: ' num2str(round(newPoint(3)))]);
hold on;
plot(newPoint(2), newPoint(1), 'g+');


sagittal_slice = overlayFunctionalData(anat_vol_scaled, funct_scaled, 'sagittal', newPoint(1), functional_opacity);
figure;
image(sagittal_slice);
axis image;
title(['Sagittal slice: ' num2str(round(newPoint(1)))]);
hold on;
plot(newPoint(3), newPoint(2), 'g+');



coronal_slice = overlayFunctionalData(anat_vol_scaled, funct_scaled, 'coronal', newPoint(2), functional_opacity);
figure;
image(coronal_slice);
axis image;
title(['Coronal slice: ' num2str(round(newPoint(2)))]);
hold on;
plot(newPoint(3), newPoint(1), 'g+');
