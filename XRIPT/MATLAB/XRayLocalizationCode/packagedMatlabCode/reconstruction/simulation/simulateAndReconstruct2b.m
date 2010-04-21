%%given a simulated actualCalibratedSystem, and an expected
%%calibrationSysytem (that is meant to be the result of a calibration
%%algorithm on the simulatedActualCalibratedsystem), removes calibration
%%fiducials from both systems, adds reconFiducials to both systems, and
%%performs a simulated reconstruction given a reconstruction imaging output
%%delta, and a range over which the recondstruction fiducials can exist

function [simulatedValues, actualCalibratedSystem, expectedCalibratedSystem, resnorm, iters, exitflag] = ...
    simulateAndReconstruct2b(...
    actualCalibratedSystem,...
    expectedCalibratedSystem,...
    fiducialDelta,...
    reconFiducials,...
    reconOutputDelta)
    
    
    %%taking a calibrated system, and adding random monkey fiducials, then collecitng the data. Keep doing 
    %%this untill we get a valid set of data
    hasProjected = 0;
    tries = 0;
    while (hasProjected == 0)
        
        if (tries>20)
            error('calibrated system is too badly calibrated to generate useful reconstruction data-',...
            'tries exceeded in simRecon2b');
        end            
        resetToRandomFiducials(...
            actualCalibratedSystem,...
            reconFiducials,...
            fiducialDelta);    
    
        %%simulatedValues collected from a simulated calibrated system
        simulatedValues = collectSimulatedData1(actualCalibratedSystem, reconOutputDelta); 
        
        %%checking to make sure our simulatedValues are in bounds of the the
        %%actualCalibratedSystem
        hasProjected = Simulator.OutputGenerator.outputInBounds(simulatedValues, actualCalibratedSystem);
        tries = tries +1;
    end
    
        
    %%adding the same number of fiducials to the expectedCalibrated
    %%system
    resetToRandomFiducials(...
        expectedCalibratedSystem,...
        reconFiducials,...
        fiducialDelta);
    
    
    %perturbing expectedCalibrated system unitll its output matches
    %simulatedValues
    [resnorm, iters, exitflag] = reconstruct2b(expectedCalibratedSystem, simulatedValues)
    
end