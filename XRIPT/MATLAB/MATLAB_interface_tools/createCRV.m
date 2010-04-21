function createCRV(name_in, ...
    subject, ...
    nativeUnits_um, ...
    FFORs, ...
    description, ...
    APG, ...
    image_vol, ...
    volume_alignment, ...
    in_dir)

filename = [in_dir '/' name_in '.crv'];
mkdir(filename);
mkdir([filename '/data']);

xmlStruct.name=name_in;
xmlStruct.dateCreated=datestr(now, 'yyyymmdd');
xmlStruct.dateLastModified=datestr(now, 'yyyymmdd');
xmlStruct.subject = subject;
xmlStruct.volumeAlignment = volume_alignment;

nativeUnits.type='volume';
nativeUnits.SI_length=mat2str(nativeUnits_um);
nativeUnits.SI_units='um';
xmlStruct.nativeUnits=nativeUnits;

for i=1:size(FFORs,2)
    coregisteredFFOR_.FFOR_name = FFORs{i}.name;
    coregisteredFFOR_.transfromFromFFORToNativeVolume = mat2str(FFORs{i}.transfromFromFFORToNativeVolume);
    coregisteredFFOR_.FFOR_description=FFORs{i}.description;

    coregisteredFFOR(i)=coregisteredFFOR_;
    
    % put this inside the loop in case there aren't any FFORs
    crFFORs.coregisteredFFOR=coregisteredFFOR;
    xmlStruct.coregisteredFFORs=crFFORs;
end




% for i=1:size(APs,2)
%     anatomicalPlanes_.name = APs{i}.name;
%     
%     if(isfield(APs{i}, 'description'))
%         anatomicalPlanes_.description=APs{i}.description;
%     end
% 
%     AP0.unitNormalVector=mat2str(APs{i}.ap0.unitNormalVector);
%     if(isfield(APs{i}.ap0, 'pointInPlane'))
%         AP0.pointInPlane=mat2str(APs{i}.ap0.pointInPlane);
%     end
%     
%     RL0.unitNormalVector=mat2str(APs{i}.rl0.unitNormalVector);
%     if(isfield(APs{i}.rl0, 'pointInPlane'))
%         RL0.pointInPlane=mat2str(APs{i}.rl0.pointInPlane);
%     end
%     
%     DV0.unitNormalVector=mat2str(APs{i}.dv0.unitNormalVector);
%     if(isfield(APs{i}.dv0, 'pointInPlane'))
%         DV0.pointInPlane=mat2str(APs{i}.dv0.pointInPlane);
%     end
%     
%     anatomicalPlanes_.AP0=AP0;
%     anatomicalPlanes_.RL0=RL0;
%     anatomicalPlanes_.DV0=DV0;
%     
%     anatomicalPlanes(i)=anatomicalPlanes_;
% 
%     APGs.anatomicalPlanes=anatomicalPlanes;
%     xmlStruct.anatomicalPlanesGroups=APGs;
% end


xmlStruct.description = description;

xmlString = struct2xml(xmlStruct);


xmlString = [xmlString APG];

file_id = fopen([filename '/info.xml'], 'w');
fprintf(file_id,'<?xml version="1.0"?>\n<CRV>\n%s</CRV>\n', xmlString);
fclose(file_id);

writebfile(image_vol, [filename '/data/img']);

% if(nargin >= 8)
%     writebfile(mask_vol, [filename '/data/mask']);
% end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function writebfile(vol, stem)
voldim = size(vol);
nslices = voldim(1);
ext='bfloat';
for slice = 0:nslices-1
    % fprintf('Saving Slice %3d\n',slice);
    fname = sprintf('%s_%03d.%s',stem,slice,ext);
    y = shiftdim(vol(slice+1,:,:,:),1);
    
    BFileName = fname;

    Endian = 0;

    BFileName = deblank(BFileName);
    kf = findstr(BFileName,'.bfloat');

    precision = 'float32';
    Base = BFileName(1:kf-1);


    HdrFile   = strcat(Base,'.hdr');

    %%% Open the header file %%%%
    fid=fopen(HdrFile,'w');
    if fid == -1
        fprintf(2, 'Could not open header %s for writing\n',HdrFile);
        return;
    end

    ndy = length(size(y));
    nR = size(y,1);
    nC = size(y,2);
    nD = prod(size(y))/(nR*nC);

    %%%% Write the Dimension to the header %%%%
    fprintf(fid,'%d %d %d %d\n',nR,nC,nD,Endian); % 0=big-endian
    fclose(fid);

    %%% Open the bfile %%%%
    EndianFlag = 'b';
    fid=fopen(BFileName,'w',EndianFlag);
    if fid == -1
        fprintf(2, 'Could not open bfile %s for writing\n',BFileName);
        return;
    end

    %%%% Transpose into row-major format %%%%
    y = reshape(y, [nR nC nD]);
    y = permute(y, [2 1 3]);

    %%%%% Save the Slice %%%%%
    count = fwrite(fid,y,precision);
    fclose(fid);

    if(count ~= prod(size(y)))
        fprintf(2, 'Did not write correct number of items (%d/%d)',...
            count,prod(size(y)));
        return;
    end

end


