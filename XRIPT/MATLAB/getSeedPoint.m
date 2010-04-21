
%This function returns a seed point for the starting contour of the snakes
%algorithm.  To attain an optimal solution, the seed point must be located
%inside the low intensity fiducial region.
%Input:  subimage I
%Outputs: seed point location point (Cx,Cy)
function [Cx,Cy] = getSeedPoint(I)

%Compute the image histogram 
[counts,bins] =imhist(I,256);
counts = counts';
bins = bins';

warning off all
err = [];

%Fit several different orders of polynomial to the pixel count data, and
%compute the residue for each one to find the best fit to the data.
for jj=15:35
    clear p y
    p = polyfit(bins,counts,jj);
    y = polyval(p,bins);
    err(end+1) = sum((y-counts).^2);
end
[C,i] = min(err);

bestFitp = polyfit(bins,counts,i+14);

clear y
y = polyval(bestFitp,bins);


%Find the local maxs and mins of the polynomial data.  These extrema will
%give a good indication of local areas of high pixel count as a finction of
%intensity, and they are more easy to parse out than the pixel count data
%itself.
[xmax,imax,xmin,imin] = extrema(y);

%The intensity range associated with a fiducial is usually evident on the
%histogram as a peak at a low intensity value.  Finding this peak and its
%adjacent local minima will help pinpoint where the majority of the
%fiducial pixels are located, so they can be weighted more heavily in the
%weight matrix.

%Find the most likely local min and max combination corresponding to the
%fiducial.  
[B,ix] = sort(imax,'ascend');
B2 = [];
for ii=1:length(B)
    clear maxTemp
    maxTemp = max(counts(1,1:B(ii)));
    if maxTemp > 10 %Filter out false polynomial extrema
        B2(end+1) = B(ii);
    else
        continue;
    end
end
max1index = B2(1);
binValue1 = bins(max1index);
localMax1 = polyval(bestFitp,binValue1);

aLeftMin = 1;
binValue = bins(aLeftMin);    
localMin1 = polyval(bestFitp,binValue);

%For the right Side
b = find(imin > max1index);
if ~isempty(b)
    for ii=1:length(b)
        aRight(ii) = imin(b(ii));
    end
    aRightMin = min(aRight);
else
    aRightMin = 1;    
end
binValue2 = bins(aRightMin);
localMin2 = polyval(bestFitp,binValue2);

%Find true max value between the two wells to either side of the localMax
[maxCounts,index] = max(counts(1,aLeftMin:aRightMin));
maxIvalue = bins(index);


%Get minimum intensity value corresponding to the well adjacent to the
%fiducial peak.
minIvalue = bins(aRightMin);
minCounts = counts(aRightMin);


[r,c] = size(I);

%Create a weight matrix the same size as the subimage.
weightMatrix2 = zeros(r,c);

%Find the locations of all the pixels in the subimage with intensity <=
%fiducial local max peak intensity value.
[rows,cols] = find(I <= maxIvalue);

%Exponentially weight these intensity values according to e(-I).
for ii=1:length(rows);
    %weightMatrix(rows(ii),cols(ii)) = 1;
    weightMatrix2(rows(ii),cols(ii)) = exp(-1*I(rows(ii),cols(ii)));
end

%Find the locations of all the pixels in the subimage with intensities
%between the local max and the local min. These likely correspond the
%fiducial boundary pixels.
%Weight these pixels according to e(-10(I-maxValue));
[rows2,cols2] = find((I > maxIvalue) & (I <= minIvalue));
for jj=1:length(rows2)
    weightMatrix2(rows2(jj),cols2(jj)) = exp(-10*(I(rows2(jj),cols2(jj))-maxIvalue));
end

%All other pixels are considered to be background and are weighted 0.
%The seed point is computed as the centroid of the weight matrix.
[Cx,Cy] = centroid(weightMatrix2);


%%%------------------------------------------------------------------------



