function [img] = raw2mat(rawFilePath)

fileId = fopen(rawFilePath, 'r');

img = fread(fileId, 'uint16')';

fclose(fileId);

img=reshape(img,1024,1000);

img=rot90(img);

img=img(end:-1:1,:);

img=uint16(img);

img=swapbytes(img);
img = imrotate(img,180);
