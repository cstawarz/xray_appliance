function vol = getCRVVolume(crvPath)

% ARGIN: crvPath = path to CRV.
% ARGOUT: a double 3D matrix that contains the volume data of the CRV

vol = [];

stem = 'img';
ext = 'bfloat';

if(exist(crvPath) == 7)
    dataPath = [crvPath '/data'];
    if(exist(dataPath) == 7)
        firstslice = 0;
        nslices = 0;
        slice = firstslice;
        fname = sprintf('%s_%03d.hdr',stem,slice);
        fid = fopen([crvPath '/data/' fname],'r');
        while(fid ~= -1)
            hdr = fscanf(fid,'%d',[1,4]);
            Nrows  = hdr(1);
            Ncols  = hdr(2);
            Ndepth = hdr(3);
            endian = hdr(4);
            fclose(fid);
            nslices = nslices + 1;
            slice   = slice + 1;
            fname = sprintf('%s_%03d.hdr',stem,slice);
            fid = fopen([crvPath '/data/' fname],'r');
        end

        if(nslices == 0)
            fprintf(2, 'ERROR: cannot find volume matching %s\n',stem);
            return;
        end

        vol = zeros(nslices,Nrows,Ncols,Ndepth);
        for slice = firstslice : firstslice + nslices - 1
            % fprintf('Loading Slice %3d\n',slice);
            fname = sprintf('%s_%03d.%s',stem,slice,ext);
            n = slice-firstslice+1;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            y = [];


            BFileList = [crvPath '/data/' fname];
            nRuns = size(BFileList,1);

            for r = 1:nRuns,

                BFileName = deblank(BFileList(r,:));
                kf = findstr(BFileName,'.bfloat');

                precision = 'float32';
                Base = BFileName(1:kf-1);

                %%% Open the header file %%%%
                HdrFile = strcat(Base,'.hdr');
                fid=fopen(HdrFile,'r');
                if fid == -1
                    fprintf(2, 'Could not open %s file',HdrFile);
                    return;
                end

                %%%% Read the Dimension from the header %%%%
                hdr=fscanf(fid,'%d',[1,4]);
                fclose(fid);
                nR  = hdr(1);
                nC  = hdr(2);
                nD  = hdr(3);
                Endian = hdr(4);

                %%%% Open the bfile %%%%%
                if(Endian == 0) fid=fopen(BFileName,'r','b'); % Big-Endian
                else            fid=fopen(BFileName,'r','l'); % Little-Endian
                end
                if fid == -1
                    fprintf(2, 'Could not open %s file',BFileName);
                    return;
                end

                %%% Read the file in bfile %%%
                [z count] = fread(fid,[nR*nC*nD],precision);
                fclose(fid);
                if(count ~= nR*nC*nD)
                    fprintf(2, 'Read %d from %s, expecting %d\n',...
                        count,BFileName,nR*nC*nD);
                    return;
                end

                %% Reshape into image dimensions %%
                z = reshape(z,[nC nR nD]);

                %%% Transpose because matlab uses row-major %%%
                z = permute(z,[2 1 3]);

                if(size(z,1) == 1 & size(z,3) == 1)
                    y(:,:,r) = z;
                else
                    y(:,:,:,r) = z;
                end

            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            if(size(y,1) == 1 & size(y,3) == 1)
                vol(n,:,:)  = y;
            else
                vol(n,:,:,:) = y;
            end

        end

    else
        fprintf(2, '%s doesn''t exist', dataPath);
    end
else
    fprintf(2, '%s doesn''t exist', crvPath);
end











