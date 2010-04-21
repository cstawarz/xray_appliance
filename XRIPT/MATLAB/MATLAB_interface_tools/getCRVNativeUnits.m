function native_units = getCRVNativeUnits(crvPath)


% ARGIN: crvPath = path to CRV.
% ARGOUT: native_units = a structure describing the native units

native_units = [];

if(exist(crvPath) == 7)
    infoPath = [crvPath '/info.xml'];
    if(exist(infoPath) == 2)
        DOM=xmlread(infoPath);
        native_units_object = DOM.getElementsByTagName('nativeUnits').item(0);

        native_units.type = strtrim(char(native_units_object.getElementsByTagName('type').item(0).getFirstChild.getData));
        native_units.SI_units = strtrim(char(native_units_object.getElementsByTagName('SI_units').item(0).getFirstChild.getData));

        temp=char(native_units_object.getElementsByTagName('SI_length').item(0).getFirstChild.getData);
        temp=strtrim(temp);
        temp=temp(2:end-1);
        eval(['native_units.SI_length = [' temp '];']);
    else
        fprintf(2, '%s doesn''t exist', infoPath);
    end
else
    fprintf(2, '%s doesn''t exist', crvPath);
end

return;
