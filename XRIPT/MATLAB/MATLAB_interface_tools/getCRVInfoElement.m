function retval = getCRVInfoElement(crvPath, element_name)

% ARGIN: crvPath = path to CRV.
%        element_name = the xml element ot return...currently only works
%        for single element items
% ARGOUT: a string that containes the value of the XML element indicated by
%         'element_name'.  It also removes all newline characters
%
% example usage:
% name=getCRVInfoElement('/Volumes/data/Animals/03-14 Jan/Processed_data/MRI_bundles/CRV/anatomical/CRV_MRMask_Jan_GoldStandard_Hans01.crv/', 'name');


retval = '';

if(exist(crvPath) == 7)
    infoPath = [crvPath '/info.xml'];
    if(exist(infoPath) == 2)
        DOM=xmlread(infoPath);
                
        retval = char(DOM.getElementsByTagName(element_name).item(0).getFirstChild.getData);        
        retval = retval(find(retval ~= char(10)));
        retval=strtrim(retval);
    else
        fprintf(2, '%s doesn''t exist', infoPath);
    end
else
    fprintf(2, '%s doesn''t exist', crvPath);
end

return;
