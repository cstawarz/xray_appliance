%%dicomReader: reads a directory with dicom images into a matlab array
%WARNING!
%everything in dicomreader directory must be a dicom file- no way to tell
%what it is reading
function[A] = dicomReader(dicomDirectory)

displ = 1; %%debug 

allfilenames = ls('-1', dicomDirectory); %%forcing ls to return a single column

[filename, remainder] = strtok(allfilenames); %%filename is the first token, remainder is the rest of the string
A(:,:,1) = dicomread([dicomDirectory,filename]);

i = 2;
%%looping over every filename token, reading and appending to A
while(length(remainder~=0))
    [filename, remainder] = strtok(remainder); %%filename is the first token, remainder is the rest of the string
    if(length(filename)~=0)
    A(:,:,i) = dicomread([dicomDirectory, filename]);
    if(displ)
        i
        imshow(A(:,:,i),[])
    end
    end
    i = i + 1; 
end
