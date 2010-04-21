function dat = getCRV(crv_path)

% ARGIN: crvPath = path to CRV (needs to be a full path, i.e not 
%                  '~/CRV_animal_type/', but 
%                  '/Users/username/CRV_animal_type').
% ARGOUT: dat = a DMR structure that contains the meta-data associated  
%               with the CRV

% example usage:
% dat=getCRV('/Volumes/data/Animals/03-14 Jan/Processed_data/MRI_bundles/CRV/anatomical/CRV_MRMask_Jan_GoldStandard_Hans01.crv/');

dat.subject = getCRVInfoElement(crv_path, 'subject');
dat.name = getCRVInfoElement(crv_path, 'name');
dat.description = getCRVInfoElement(crv_path, 'description');
dat.date_created = getCRVInfoElement(crv_path, 'dateCreated');
dat.date_last_modified = getCRVInfoElement(crv_path, 'dateLastModified');
dat.img = getCRVVolume(crv_path);
dat.native_units = getCRVNativeUnits(crv_path);
dat.anatomical_planes_groups = getCRVAnatomicalPlanesGroups(crv_path);
dat.transforms = getCRVTransforms(crv_path);






