
baseCRVpath = '/Users/bkennedy/Documents/sandbox/XRayAppliance/XRayData/CRV/Mieke/anatomicals/CRV_MRanatomical_Mieke_GoldStandardLRReflectedHans01.crv/';
%mask=getCRVVolume(baseCRVpath, 1);
xforms = getCRVTransforms(baseCRVpath);
xforms{1}.name = xforms{1}.name(2:end-7);
xforms{1}.description = xforms{1}.description(2:end-7);

data_dir = '/Users/bkennedy/Desktop/filesTransform_mieke/';

files=dir([data_dir '*.mat']);

for ii=1:length(files)

filename = files(ii).name;
trimmed_filename = filename(1:end-4);

image = load([data_dir files(ii).name]);

name = ['CRV_MRFunctional_Mieke_' trimmed_filename '_LRReflectedHans01'];
subject='Mieke';
native_units = [500 500 500];
description = [name ' in the gold standard frame with a reflection about the LR (x) axis.  [smoothies = 1, spikies = 2, cubies = 3].  13 = smoothies - cubies (which, due to the MION signal inversion, gives you negative values in regions that prefer smoothies)'];
APG = ['  <AnatomicalPlanesGroups>' char(10) '    <AnatomicalPlanes>' char(10) '      <name>native</name>' char(10) '      <AP0>' char(10) '        <unitNormalVector direction="anterior">[0 -1 0]</unitNormalVector>' char(10) '        <pointInPlane>[0 149 0]</pointInPlane>' char(10) '      </AP0>' char(10) '      <RL0>' char(10) '        <unitNormalVector direction="right">[1 0 0]</unitNormalVector>' char(10) '      </RL0>' char(10) '      <DV0>' char(10) '        <unitNormalVector direction="dorsal">[0 0 -1]</unitNormalVector>' char(10) '      </DV0>' char(10) '    </AnatomicalPlanes>' char(10) '  </AnatomicalPlanesGroups>' char(10)];


createCRV(name, subject, native_units, xforms, description, APG, image.allslice_resliced_fs);

end
