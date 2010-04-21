function [frame] = convertBundleToFrame(xrayBundle)

fprintf(2, 'starting convertBundleToFrame(%s)\n', xrayBundle);

    reconCentersName = strcat(xrayBundle, '/3D_reconstruction/recon_Native.mat');
    reconCenters = load(reconCentersName);


    frame = [];
    elements = [];
    name = xrayBundle(max(findstr(xrayBundle, '/'))+1:end);
    frame.name = name;

    pointNames = fieldnames(reconCenters.recon_centers);
    numPoints = size(pointNames,1);
   

    outputIndex = 0;
    for ii=1:length(reconCenters.recon_centers.elements)

        
        pointName = reconCenters.recon_centers.elements{ii}.name;
        
        fprintf(2,'creating point: %s\n', pointName);
            outputIndex = outputIndex + 1;
            elements{outputIndex}.visibility = 'x';
            elements{outputIndex}.name = pointName;
            elements{outputIndex}.location_um = reconCenters.recon_centers.elements{ii}.location_um;
    end

%    save([xrayBundle '/3D_reconstruction/xrayFrame.mat'], 'name', 'elements');
    frame.elements = elements;

    fprintf(2, 'exiting convertBundleToFrame(%s)\n', xrayBundle);
end
