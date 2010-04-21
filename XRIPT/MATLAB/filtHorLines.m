%This function filters the horizontal line noise from an image, or subimage
%I.  The output is the filtered image Ifiltered.  


function Ifiltered = filtHorLines(I)

[rows,cols] = size(I);
%Rotate image 90 degrees.  This allows the the same algorithm to be used
%for both vertical and horizontal aline noise.
Im_rotated = imrotate(I,90); 

%Find the log of the average of the intensity values of each column of data
hor_ave_log = log((sum(Im_rotated))/cols);
%Apply a Savitsky-Golay digital smoothing polynomial filter to eliminate high
%frequency variations
hor_ave_filt = sgolayfilt(hor_ave_log,3,39);

%Find the antilog of the difference between the filtered and unfiltered data.
%E_hor is a correction factor ~=1 for each column.
E_hor = exp(hor_ave_log - hor_ave_filt);

%Apply correction factor to each column and rotate image 90 degrees to
%original orientation.
for ii=1:rows
    IhorFilt(:,ii) = Im_rotated(:,ii)/E_hor(ii);
end

Ifiltered = imrotate(IhorFilt,-90);