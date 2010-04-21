function DMR2CRV(dat, name, FFOR1, FFOR2)

mkdir(name);

if(isfield(dat, 'img'))
   save_cor(dat.img, name, 'COR');
end

if(isfield(dat, 'mask'))
   save_cor(dat.mask, name, 'COR_mask');
end

xmlStruct.name=name;
xmlStruct.dateCreated='20071227';
xmlStruct.dateLastModified='20071227';
xmlStruct.subject = dat.subject;

nativeUnits.type='volume';
nativeUnits.SI_length=mat2str(FFOR1.dimensions);
nativeUnits.SI_units='um';
xmlStruct.nativeUnits=nativeUnits;


coregisteredFFOR_.name = FFOR1.name;
coregisteredFFOR_.transfromFromFFORToNativeVolume = mat2str(FFOR1.xform);
coregisteredFFOR_.description=FFOR1.description;

coregisteredFFOR(1)=coregisteredFFOR_;

if(nargin == 4) 
coregisteredFFOR_.name = FFOR2.name;
coregisteredFFOR_.transfromFromFFORToNativeVolume = mat2str(FFOR2.xform);
coregisteredFFOR_.description=FFOR2.description;

coregisteredFFOR(2)=coregisteredFFOR_;    
end

crFFORs.coregisteredFFOR=coregisteredFFOR;
xmlStruct.coregisteredFFORs=crFFORs;

xmlStruct.map = dat.map;
xmlStruct.description = dat.description;

if(isfield(dat, 'AP'))
   AP.vector=mat2str(dat.AP.vector);
   AP.point=mat2str(dat.AP.point);
   xmlStruct.AP=AP;
end

xmlString = struct2xml(xmlStruct);

file_id = fopen([name '/info.xml'], 'w');
fprintf(file_id,'<?xml version="1.0"?>\n<CRV>\n%s</CRV>\n', xmlString);
fclose(file_id);

