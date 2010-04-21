function [image_return] = overlayFunctionalData(anat_vol_scaled, funct_scaled, slice_type, slice_number, funct_opacity);

% get the two closest image planes

%% use coronal by default
anat_slice_2D = squeeze(anat_vol_scaled(:,round(slice_number),:));
funct_slice_2D = squeeze(funct_scaled(:,round(slice_number),:));

if strcmp(slice_type, 'horizontal')
    anat_slice_2D = squeeze(anat_vol_scaled(:,:,round(slice_number)));
    funct_slice_2D = squeeze(funct_scaled(:,:,round(slice_number)));
end

if strcmp(slice_type, 'sagittal')
    anat_slice_2D = squeeze(anat_vol_scaled(round(slice_number),:,:));
    funct_slice_2D = squeeze(funct_scaled(round(slice_number),:,:));
end


%%%% Next, multiply by 63 and round to the nearest whole number
%%%% Finally, add 1, in order to make a matrix that goes from 1 to 64
anat64 = round( 63 * anat_slice_2D ) + 1;
funct64 = round(63*funct_slice_2D) + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ok, now we have made two matrices scaled from 1 to 64,
% one for the anatomical image, and the other for the T-map image
%
% The next step is to make a full RGB-image for each image,
% by looking up the corresponding rows of the gray and hot colormaps.
%
% An RGB-image is a 3D-matrix.
% It has three "colour slabs" that are joined up along the third dimension.
% The first slab is an image full of Red values.
% The second slab is an image full of Green values.
% And the third slab is an image of Blue values.

% First make 3D matrices full of zeros, to hold the values
% that we are about to create for the anatomical and T-map RGB images.
% These have three slabs in the 3rd dimension, and are the same size as 
% the anatomical and the funct matrices in the first two dimensions.

anat_RGB = zeros(size(anat64,1), size(anat64,2), 3);
                    %%% This will hold the anatomical image's RBG values
                    
funct_RGB = zeros(size(funct64,1), size(funct64,2), 3);
                    %%% This will hold the T-map image's RBG values

gray_cmap = repmat((0:1/64:1)',1,3);

funct_cmap = [zeros(16,1) flipud((0:1/15:1)') ones(16,1); ...
              zeros(16,2) flipud((0:1/16:1-1/16)'); ...
              [(1/16:1/16:1)' zeros(16,2)]; ...
              [ones(16,1) (1/16:1/16:1)' zeros(16,1)]];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Ok, now we have copies of the gray and funational colormap matrices,
% with their 64 rows each, we have anatomical and T-map images scaled
% from 1 to 64, so that we can match each value to a colormap matrix row,
% and we have empty place-holder matrices to store the looked-up RGB values.
% So, we're ready to look-up and store the appropriate RGB values. 


for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B

    %%% Each entry in each 1-to-64-scaled matrix gives us a row 
    %%% in the colormap matrix to go look-up.   
    %%% That row has three columns: the R, G and B values for that colour.
    gray_cmap_rows_for_anat = anat64;
    cmap_rows_for_funct = funct64;
    
    %%% We'll read in one of these R, G, or B values at a time,
    %%% depending on which colour-slab we're building.
    %%% The colormap entry we want is in the RGB_dim-th column,
    %%% and in the row that we determined above.
    %%% Note that we're actually looking up all the rows at once,
    %%% because we're giving Matlab an entire matrix in the row-position.
    
    colour_slab_vals_for_anat = gray_cmap(gray_cmap_rows_for_anat, RGB_dim);
    colour_slab_vals_for_funct = funct_cmap(cmap_rows_for_funct, RGB_dim);
    
    %%%% These colour-slab values turn out to be in column vector format,
    %%%% and need to be reshaped into being the same size as image matrices.
    
    anat_RGB(:,:,RGB_dim) = reshape( colour_slab_vals_for_anat, size(anat64));
    funct_RGB(:,:,RGB_dim) = reshape( colour_slab_vals_for_funct, size(funct64));

end;  % End of loop through the RGB dimension. 


% Let's make the opacity range from 0 to 1, with 0 being fully transparent.


%%%% Make a place-holder matrix to hold the compound weighted-sum image



compound_RGB = zeros(size(anat64,1), size(anat64,2), 3);
                    %%% The anat and the T-map are the same size,
                    %%% we could have chosen either.
                    
%%% Now build up the compound image, one colour-slab at a time, like above.
%%% Where the T-map is below threshold, we only want the anatomical's values.
%%% Where the T-map is above-threshold, we want a weighted sum 
%%% of the T-map RGB values and the anatomical's RGB values.
                
for RGB_dim = 1:3,  %%% Loop through the three slabs: R, G, and B

    compound_RGB(:,:,RGB_dim) = ...
        ((funct64 - ones(size(funct64)) == 0)) .* ...    % Where T-map is below threshold
            anat_RGB(:,:,RGB_dim) + ...  
        (funct64 - ones(size(funct64)) > 0).* ...      % Where T-map is below threshold
            ( (1-funct_opacity) * anat_RGB(:,:,RGB_dim) + ...
               funct_opacity * funct_RGB(:,:,RGB_dim) );
               
%     compound_RGB(:,:,RGB_dim) = ...
%         ((pos_funct64 - ones(size(pos_funct64)) == 0) .* ...
%          (neg_funct64 - ones(size(neg_funct64)) == 0)) .* ...    % Where T-map is below threshold
%             anat_RGB(:,:,RGB_dim) + ...  
%         (pos_funct64 - ones(size(pos_funct64)) > 0).* ...      % Where T-map is above threshold
%             ( (1-funct_opacity) * anat_RGB(:,:,RGB_dim) + ...
%                funct_opacity * pos_funct_RGB(:,:,RGB_dim) ) + ...
%         (neg_funct64 - ones(size(neg_funct64)) > 0).* ...      % Where T-map is below threshold
%             ( (1-funct_opacity) * anat_RGB(:,:,RGB_dim) + ...
%                funct_opacity * neg_funct_RGB(:,:,RGB_dim) );
               
                        % Opacity-weighted sum of anatomical and T-map
end;

%%%% Before displaying our newly-made compound image,
%%%% we have to make sure that none of the RGB values exceeds 1.

image_return = min(compound_RGB,1);
