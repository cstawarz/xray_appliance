function [raw_img] = mat2raw(img, rawFile)



img = imrotate(img,-180);
img=swapbytes(img);
img=img(end:-1:1,:);
img=rot90(img);
img=rot90(img);
img=rot90(img);
raw_img=reshape(img,1,1024000);

if(nargin == 2)
    fileId = fopen(rawFile, 'w');
    fwrite(fileId,raw_img,'uint16');
    fclose(fileId);
end

