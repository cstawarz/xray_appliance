function [average_system] = averageSystems(calibrated_systems)



sdp_1_translation = [];
sdp_2_translation = [];
sdp_1_rotation = [];
sdp_2_rotation = [];
s1_translation = [];
s2_translation = [];
s1_rotation = [];
s2_rotation = [];
d1_translation = [];
d2_translation = [];
d1_rotation = [];
d2_rotation = [];

for ii = 1:length(calibrated_systems)
    if(calibrated_systems{ii}.guess.numDetectors ~= 2)
        average_system = [];
        fprint(2, 'system average only works with 2 detectors right now\n');
        return;
    end
    
    if(calibrated_systems{ii}.guess.numDetectors ~= calibrated_systems{1}.guess.numDetectors || ...
            ~isequal(calibrated_systems{ii}.guess.rotationSpread, calibrated_systems{1}.guess.rotationSpread) || ...
            ~isequal(calibrated_systems{ii}.guess.detectorDistances, calibrated_systems{1}.guess.detectorDistances) || ...
            ~isequal(calibrated_systems{ii}.guess.sourceDistances, calibrated_systems{1}.guess.sourceDistances))
        average_system = [];
        fprintf(2, 'system guesses need to match: %d\n', ii);
        return;
    end
    

    sdp_1_translation = [sdp_1_translation; calibrated_systems{ii}.sdp{1}.translation];
    sdp_2_translation = [sdp_2_translation; calibrated_systems{ii}.sdp{2}.translation];
    sdp_1_rotation = [sdp_1_rotation; calibrated_systems{ii}.sdp{1}.rotation];
    sdp_2_rotation = [sdp_2_rotation; calibrated_systems{ii}.sdp{2}.rotation];

    s1_translation = [s1_translation; calibrated_systems{ii}.sdp{1}.source.translation];
    s2_translation = [s2_translation; calibrated_systems{ii}.sdp{2}.source.translation];
    s1_rotation = [s1_rotation; calibrated_systems{ii}.sdp{1}.source.rotation];
    s2_rotation = [s2_rotation; calibrated_systems{ii}.sdp{2}.source.rotation];
    d1_translation = [d1_translation; calibrated_systems{ii}.sdp{1}.detector.translation];
    d2_translation = [d2_translation; calibrated_systems{ii}.sdp{2}.detector.translation];
    d1_rotation = [d1_rotation; calibrated_systems{ii}.sdp{1}.detector.rotation];
    d2_rotation = [d2_rotation; calibrated_systems{ii}.sdp{2}.detector.rotation];
end


new_sdp1_rotation = mean(sdp_1_rotation,1);
new_sdp2_rotation = mean(sdp_2_rotation,1);
new_sdp1_translation = mean(sdp_1_translation,1);
new_sdp2_translation = mean(sdp_2_translation,1);

new_s1_rotation = mean(s1_rotation,1);
new_s2_rotation = mean(s2_rotation,1);
new_s1_translation = mean(s1_translation, 1);
new_s2_translation = mean(s2_translation, 1);

new_d1_rotation = mean(d1_rotation,1);
new_d2_rotation = mean(d2_rotation,1);
new_d1_translation = mean(d1_translation, 1);
new_d2_translation = mean(d2_translation, 1);


average_system = ...
    xrg_buildUnperturbedSystem1(...
    2,...
    calibrated_systems{1}.guess.rotationSpread,...
    calibrated_systems{1}.guess.detectorDistances,...
    calibrated_systems{1}.guess.sourceDistances);

average_system.getSDP(0).getDetector.setTranslationHorizontal(new_d1_translation(1));
average_system.getSDP(0).getDetector.setTranslationVertical(new_d1_translation(2));
average_system.getSDP(0).getDetector.setTranslationFromSource(new_d1_translation(3));
average_system.getSDP(0).getDetector.setRotationAboutPolar(new_d1_rotation(1));
average_system.getSDP(0).getDetector.setRotationAboutAzimuthal(new_d1_rotation(2));
average_system.getSDP(0).getDetector.setRotationAboutNormal(new_d1_rotation(3));
average_system.getSDP(0).getSource.setVerticalTranslation(new_s1_translation(1));
average_system.getSDP(0).getSource.setHorizontalTranslation(new_s1_translation(2));
average_system.getSDP(0).getSource.setTranslationToDetectorArray(new_s1_translation(3));

average_system.getSDP(1).getDetector.setTranslationHorizontal(new_d2_translation(1));
average_system.getSDP(1).getDetector.setTranslationVertical(new_d2_translation(2));
average_system.getSDP(1).getDetector.setTranslationFromSource(new_d2_translation(3));
average_system.getSDP(1).getDetector.setRotationAboutPolar(new_d2_rotation(1));
average_system.getSDP(1).getDetector.setRotationAboutAzimuthal(new_d2_rotation(2));
average_system.getSDP(1).getDetector.setRotationAboutNormal(new_d2_rotation(3));
average_system.getSDP(1).getSource.setVerticalTranslation(new_s2_translation(1));
average_system.getSDP(1).getSource.setHorizontalTranslation(new_s2_translation(2));
average_system.getSDP(1).getSource.setTranslationToDetectorArray(new_s2_translation(3));

average_system.setSDPRotation( ...
    new_sdp1_rotation(1), ...
    new_sdp1_rotation(2), ...
    new_sdp1_rotation(3), ...
    0);
average_system.setSDPTranslation( ...
    new_sdp1_translation(1), ...
    new_sdp1_translation(2), ...
    new_sdp1_translation(3), ...
    0);

average_system.setSDPRotation( ...
    new_sdp2_rotation(1), ...
    new_sdp2_rotation(2), ...
    new_sdp2_rotation(3), ...
    1);
average_system.setSDPTranslation( ...
    new_sdp2_translation(1), ...
    new_sdp2_translation(2), ...
    new_sdp2_translation(3), ...
    1);


return



