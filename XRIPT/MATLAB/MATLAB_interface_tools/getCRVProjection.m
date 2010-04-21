function new_point = getCRVProjection(crv_path, point, FFOR_name)


% ARGIN: crvPath = path to CRV (needs to be a full path, i.e not 
%                  '~/CRV_animal_type/', but 
%                  '/Users/username/CRV_animal_type').
%        point = a point in the FFOR 3-space in the form: point = [x y z]
%        FFOR_name = a string that names the specific FFOR 3-space that
%        'point' is in
% ARGOUT: new_point = the point transformed to the 3-space in the CRV



%% this returns a point that is transformed from the FFOR named 'FFOR_name'
%% to a point that is in the native cooridinates of the volume
%%
%% example usage
%%
%% find projection of [4.2070e+04 6.4787e+04 6.6701e+04] from
%% FFOR_PapanastassiouPlasticValence01_JanMR to
%% CRV_MRMask_Jan_GoldStandard_Hans01

%  >> ffor_point = [4.2070e+04 6.4787e+04 6.6701e+04];
%  >> crvpath = '/Volumes/data/Animals/03-14 Jan/Processed_data/MRI_bundles/CRV/anatomical/CRV_MRMask_Jan_GoldStandard_Hans01.crv/'
%  >> new_point = getCRVProjection(crvpath, ffor_point, 'FFOR_PapanastassiouPlasticValence01_JanMR');

%% this give a point in the CRV volume that corresponds to the point in the
%% FFOR


xforms = getCRVTransforms(crv_path);

if(nargin < 3)
    fprintf(2, 'crvVolumePoint=getCRVProjection(''crvPath'', [x y z], ''FFOR name''\n');
end

xform = [];

for ii=1:length(xforms)
    if(strcmp(xforms{ii}.name, FFOR_name))
        xform = xforms{ii}.transfromFromFFORToNativeVolume;
    end
end

if(isempty(xform))
    new_point = [0 0 0];
    return;
end


point_2_xform = [point 1]';
new_point = xform*point_2_xform;
new_point = new_point(1:3)';
