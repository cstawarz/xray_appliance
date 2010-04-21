function [recon_centers] = reconstructBundle(system_geometry, rotation_spread, detector_distances, source_distances, xray_bundle)

if(~isequal(size(detector_distances), size(source_distances)))
    fprintf(2, 'detector_distances must be same size as source_distances\n');
end

elements = [];
recon_centers = [];            

% build a system geometry with a guess
calibratedSystem = ...
    xrg_buildUnperturbedSystem1(...
    length(detector_distances),...
    rotation_spread,...
    detector_distances,...
    source_distances);

fprintf(2, '1\n%s\n\n', char(calibratedSystem.toString()));

% modify by all of the availble params
calibratedSystem.getSDP(0).getDetector.setTranslationHorizontal(system_geometry{1}.detector.translation(1));
calibratedSystem.getSDP(0).getDetector.setTranslationVertical(system_geometry{1}.detector.translation(2));
calibratedSystem.getSDP(0).getDetector.setTranslationFromSource(system_geometry{1}.detector.translation(3));
calibratedSystem.getSDP(0).getDetector.setRotationAboutPolar(system_geometry{1}.detector.rotation(1));
calibratedSystem.getSDP(0).getDetector.setRotationAboutAzimuthal(system_geometry{1}.detector.rotation(2));
calibratedSystem.getSDP(0).getDetector.setRotationAboutNormal(system_geometry{1}.detector.rotation(3));
calibratedSystem.getSDP(0).getSource.setVerticalTranslation(system_geometry{1}.source.translation(1));
calibratedSystem.getSDP(0).getSource.setHorizontalTranslation(system_geometry{1}.source.translation(2));
calibratedSystem.getSDP(0).getSource.setTranslationToDetectorArray(system_geometry{1}.source.translation(3));

calibratedSystem.getSDP(1).getDetector.setTranslationHorizontal(system_geometry{2}.detector.translation(1));
calibratedSystem.getSDP(1).getDetector.setTranslationVertical(system_geometry{2}.detector.translation(2));
calibratedSystem.getSDP(1).getDetector.setTranslationFromSource(system_geometry{2}.detector.translation(3));
calibratedSystem.getSDP(1).getDetector.setRotationAboutPolar(system_geometry{2}.detector.rotation(1));
calibratedSystem.getSDP(1).getDetector.setRotationAboutAzimuthal(system_geometry{2}.detector.rotation(2));
calibratedSystem.getSDP(1).getDetector.setRotationAboutNormal(system_geometry{2}.detector.rotation(3));
calibratedSystem.getSDP(1).getSource.setVerticalTranslation(system_geometry{2}.source.translation(1));
calibratedSystem.getSDP(1).getSource.setHorizontalTranslation(system_geometry{2}.source.translation(2));
calibratedSystem.getSDP(1).getSource.setTranslationToDetectorArray(system_geometry{2}.source.translation(3));

calibratedSystem.setSDPRotation( ...
    system_geometry{1}.rotation(1), ...
    system_geometry{1}.rotation(2), ...
    system_geometry{1}.rotation(3), ...
    0);
calibratedSystem.setSDPTranslation( ...
    system_geometry{1}.translation(1), ...
    system_geometry{1}.translation(2), ...
    system_geometry{1}.translation(3), ...
    0);

calibratedSystem.setSDPRotation( ...
    system_geometry{2}.rotation(1), ...
    system_geometry{2}.rotation(2), ...
    system_geometry{2}.rotation(3), ...
    1);
calibratedSystem.setSDPTranslation( ...
    system_geometry{2}.translation(1), ...
    system_geometry{2}.translation(2), ...
    system_geometry{2}.translation(3), ...
    1);


fprintf(2, '2\n%s\n\n', char(calibratedSystem.toString()));

% project each xray element
RHSFile = [char(xray_bundle) '/Image_processing/RHS.mat'];
fiducialsFile = [char(xray_bundle) '/Image_processing/xray_elements.mat'];

if(exist(RHSFile) == 2)
    if(exist(fiducialsFile) == 2)
        
        
        RHS_data = load (RHSFile);

        fprintf(2, 'num fids: %d\n', RHS_data.RHS_Verbose.numFids);
        
        if(RHS_data.RHS_Verbose.numFids > 0)

            RHS_reconstruct = RHS_data.RHS_Verbose;

            %%reconstruction
            %% The next call performs the reconstruction:  It takes the calibrated
            %% system ("expectedSystem" below) and the RHS and return a modified
            %% expected system.  The expected system is modified to contain the
            %% reconstructed 3d centers (but the parameters of the expected  system are NOT modified!)
            %% That is, one could run another construction using the returned expectedSystem.
            %% (The reconstructed 3d centers are also explicitly returned in the argument centers)
            [expectedCalibratedSystem, centers, residual, resnorm, iters, exitflag] = ...
                recon_reconstruct(calibratedSystem, RHS_reconstruct);

%            RHS = xrg_RHSVerbose2Vector(RHS_reconstruct);
%            save([char(xray_bundle) '/RHS_residual.mat'], 'RHS', 'residual');
            
            fiducials = load(fiducialsFile);
            
            if(RHS_reconstruct.numFids ~= length(centers))
                return;
            end

            for jj=1:RHS_reconstruct.numFids
                element = [];
                fid_d1 = getfield(RHS_reconstruct, 'detector1', ['fiducial' num2str(jj) 'Projection']);
                fid_d2 = getfield(RHS_reconstruct, 'detector2', ['fiducial' num2str(jj) 'Projection']);
                if(fid_d1.index ~= fid_d2.index) 
                   recon_centers = [];
                   return;
                end
                element.name = fiducials.elements{fid_d1.index}.name;
                element.location_um = centers(jj, :);
        		element.residual = residual([2*jj-1; 2*jj; 2*jj+((length(centers)*2)-1); 2*jj+(length(centers)*2)]);
                elements{jj} = element;
            end
            
            recon_centers.resnorm = resnorm;
            recon_centers.elements = elements;
        end
    end
end


