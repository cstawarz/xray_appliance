function xforms = getCRVTransforms(crvPath)

% ARGIN: crvPath = path to CRV
% ARGOUT: xforms = a cell-array of structures that contain the affine
%                  transform from FFOR_name to the CRV

% example usage:
% xforms=getCRVTransforms('/Volumes/data/Animals/03-14 Jan/Processed_data/MRI_bundles/CRV/anatomical/CRV_MRMask_Jan_GoldStandard_Hans01.crv/');


xforms = [];

if(exist(crvPath) == 7)
    infoPath = [crvPath '/info.xml'];
    if(exist(infoPath) == 2)
        DOM=xmlread(infoPath);
        coregTransforms = DOM.getElementsByTagName('coregisteredFFOR');        
        
        for k=0:coregTransforms.getLength-1
            xform = [];
            currentCoregTransform = coregTransforms.item(k);
            xform.name = strtrim(char(currentCoregTransform.getElementsByTagName('FFOR_name').item(0).getFirstChild.getData));
            xform.description = strtrim(char(currentCoregTransform.getElementsByTagName('FFOR_description').item(0).getFirstChild.getData));
            transformString = strtrim(char(currentCoregTransform.getElementsByTagName('transfromFromFFORToNativeVolume').item(0).getFirstChild.getData));
            eval(['xform.transfromFromFFORToNativeVolume = ' transformString ';']);
            xforms{k+1} = xform;
        end
    else
        fprintf(2, '%s doesn''t exist', infoPath);
    end
else
    fprintf(2, '%s doesn''t exist', crvPath);
end

return;
