
function ImNorm = image_normalization(I,norm_value)

%Norm value, either 255 or 1
I = double(I);

[r,c] = size(I);
min_value = min(min(I));
max_value = max(max(I));

range = max_value - min_value;

ImNorm = zeros(r,c);

for ii = 1:r
    for jj = 1:c
        ImNorm(ii,jj) = ((I(ii,jj) - min_value)*norm_value)/range;
    end
end
        