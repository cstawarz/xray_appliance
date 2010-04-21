function APGs = getCRVAnatomicalPlanesGroups(crvPath)

% ARGIN: crvPath = path to CRV.
% ARGOUT: a cell array of structs containing information about each
% anatomical planes group.  Each struct contains the name of the anatomical
% planes groups + the three directions.  Additional information such as the
% locatoin of the 0 planes is provided if availble


% example usage:
% APGs=getCRVAnatomicalPlanesGroups('/Volumes/data/Animals/03-14 Jan/Processed_data/MRI_bundles/CRV/anatomical/CRV_MRMask_Jan_GoldStandard_Hans01.crv/');


APGs = [];

if(exist(crvPath) == 7)
    infoPath = [crvPath '/info.xml'];
    if(exist(infoPath) == 2)
        DOM=xmlread(infoPath);
        groups = DOM.getElementsByTagName('AnatomicalPlanes');        
        
        for k=0:groups.getLength-1
            APG = [];
            currentAPG = groups.item(k);
            if(size(currentAPG.getElementsByTagName('APG_name').item(0)) == [0 0])
               fprintf(2, 'Error, AnatomincalPlanesGroups must have a name\n'); 
               return;
            end

            APG.name = char(currentAPG.getElementsByTagName('APG_name').item(0).getFirstChild.getData);
            
            if(size(currentAPG.getElementsByTagName('APG_description').item(0)) ~= [0 0])
                APG.description = char(currentAPG.getElementsByTagName('APG_description').item(0).getFirstChild.getData);
            end
            
            
            temp=char(currentAPG.getElementsByTagName('AP0').item(0).getElementsByTagName('unitNormalVector').item(0).getFirstChild.getData);
            temp=strtrim(temp);
            temp=temp(2:end-1);
            eval(['AP0.unit_normal_vector = [' temp '];']);
            AP0.direction = char(currentAPG.getElementsByTagName('AP0').item(0).getElementsByTagName('unitNormalVector').item(0).getAttribute('direction'));
            if(length(currentAPG.getElementsByTagName('AP0').item(0).getElementsByTagName('pointInPlane').item(0)) == 1)
                temp = char(currentAPG.getElementsByTagName('AP0').item(0).getElementsByTagName('pointInPlane').item(0).getFirstChild.getData);
                temp=strtrim(temp);
                temp=temp(2:end-1);
                eval(['AP0.point_in_plane = [' temp '];']);
            end
            
            temp=char(currentAPG.getElementsByTagName('DV0').item(0).getElementsByTagName('unitNormalVector').item(0).getFirstChild.getData);
            temp=strtrim(temp);
            temp=temp(2:end-1);
            eval(['DV0.unit_normal_vector = [' temp '];']);
            DV0.direction = char(currentAPG.getElementsByTagName('DV0').item(0).getElementsByTagName('unitNormalVector').item(0).getAttribute('direction'));
            if(length(currentAPG.getElementsByTagName('DV0').item(0).getElementsByTagName('pointInPlane').item(0)) == 1)
                temp = char(currentAPG.getElementsByTagName('DV0').item(0).getElementsByTagName('pointInPlane').item(0).getFirstChild.getData);
                temp=strtrim(temp);
                temp=temp(2:end-1);
                eval(['DV0.point_in_plane = [' temp '];']);
            end
            
            temp=char(currentAPG.getElementsByTagName('RL0').item(0).getElementsByTagName('unitNormalVector').item(0).getFirstChild.getData);
            temp=strtrim(temp);
            temp=temp(2:end-1);
            eval(['RL0.unit_normal_vector = [' temp '];']);
            RL0.direction = char(currentAPG.getElementsByTagName('RL0').item(0).getElementsByTagName('unitNormalVector').item(0).getAttribute('direction'));
            if(length(currentAPG.getElementsByTagName('RL0').item(0).getElementsByTagName('pointInPlane').item(0)) == 1)
                temp = char(currentAPG.getElementsByTagName('RL0').item(0).getElementsByTagName('pointInPlane').item(0).getFirstChild.getData);
                temp=strtrim(temp);
                temp=temp(2:end-1);
                eval(['RL0.point_in_plane = [' temp '];']);
            end
            
            
            APG.RL0 = RL0;
            APG.AP0 = AP0;
            APG.DV0 = DV0;

            APGs{k+1} = APG;
        end
    else
        fprintf(2, '%s doesn''t exist', infoPath);
    end
else
    fprintf(2, '%s doesn''t exist', crvPath);
end

return;
