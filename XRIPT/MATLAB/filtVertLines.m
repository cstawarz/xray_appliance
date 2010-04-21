
%This function filters the vertical line noise from an image, or subimage
%I.  The output is the filtered image Ifiltered.  

function Ifiltered = filtVertLines(I)

[rows,cols] = size(I);
%Find the log of the average of the intensity values of each column of data
ave_log = log((sum(I))/rows);
%Apply a Savitsky-Golay digital smoothing polynomial filter to eliminate high
%frequency variations
ave_filt = sgolayfilt(ave_log,3,39);
%Find the antilog of the difference between the filtered and unfiltered data.
%E_hor is a correction factor ~=1 for each column.
E = exp(ave_log-ave_filt);
%Apply correction factor to each column
for ii = 1:cols
    Ifiltered(:,ii) = I(:,ii)/E(ii);
end