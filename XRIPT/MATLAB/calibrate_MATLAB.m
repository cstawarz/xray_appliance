function [calibrated_system_MATLAB, calibrated_system_JAVA] = ...
    calibrate_MATLAB( ...
    num_detectors, ...
    rotation_spread, ...
    detectors, ...
    sources, ...
    ordered_centers, ...
    cal_obj_rhs)

expected_system = ...
    xrg_buildUnperturbedSystem1(...
    num_detectors,...
    rotation_spread,...
    detectors,...
    sources);


[calibratedSystem, paramDeltas, simpleDeltas, exitflag, iters] = ...
    calib_calibrate(expected_system, ordered_centers, cal_obj_rhs);


calibrated_system_MATLAB = [];

for ii=1:num_detectors

calibrated_system_MATLAB.sdp{ii}.translation = [ ...
    calibratedSystem.getSDPTranslation(ii-1).x ...
    calibratedSystem.getSDPTranslation(ii-1).y ...
    calibratedSystem.getSDPTranslation(ii-1).z];
calibrated_system_MATLAB.sdp{ii}.rotation = [ ...
    calibratedSystem.getSDPRotation(ii-1).x ...
    calibratedSystem.getSDPRotation(ii-1).y ...
    calibratedSystem.getSDPRotation(ii-1).z];
calibrated_system_MATLAB.sdp{ii}.source.translation = [ ...
    calibratedSystem.getSDP(ii-1).getSource.getTranslation1() ...
    calibratedSystem.getSDP(ii-1).getSource.getTranslation2() ...
    calibratedSystem.getSDP(ii-1).getSource.getTranslation3()];
calibrated_system_MATLAB.sdp{ii}.source.rotation = [ ...
    calibratedSystem.getSDP(ii-1).getSource.getRotation1() ...
    calibratedSystem.getSDP(ii-1).getSource.getRotation2() ...
    calibratedSystem.getSDP(ii-1).getSource.getRotation3()];
calibrated_system_MATLAB.sdp{ii}.detector.translation = [ ...
    calibratedSystem.getSDP(ii-1).getDetector.getTranslation1() ...
    calibratedSystem.getSDP(ii-1).getDetector.getTranslation2() ...
    calibratedSystem.getSDP(ii-1).getDetector.getTranslation3()];
calibrated_system_MATLAB.sdp{ii}.detector.rotation = [ ...
    calibratedSystem.getSDP(ii-1).getDetector.getRotation1() ...
    calibratedSystem.getSDP(ii-1).getDetector.getRotation2() ...
    calibratedSystem.getSDP(ii-1).getDetector.getRotation3()];

end

calibrated_system_MATLAB.guess.rotationSpread = rotation_spread;
calibrated_system_MATLAB.guess.detectorDistances = detectors;
calibrated_system_MATLAB.guess.sourceDistances = sources;
calibrated_system_MATLAB.guess.numDetectors = num_detectors;

calibrated_system_JAVA=calibratedSystem;


