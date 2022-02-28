//
//  XRayNIDAQ.m
//  CocoaNIDAQ
//
//  Created by Ben Kennedy on 9/13/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import "XRayNIDAQ.h"

#define MIN_OUT_VOLTAGE 0.0
#define MAX_OUT_VOLTAGE 5.0


@implementation XRayNIDAQ {
    int handle;
    
    uint8_t digitalOutput;
    double voltageOutput;
    double currentOutput;
    
    NSLock *devLock;
    NSLock *stopMonitoringLock;
    NSLock *ssLock;
    BOOL shouldMonitorUpdate;

    double source1Current_A;
    double source1Voltage_V;
    double source2Current_A;
    double source2Voltage_V;
}


- (id)init {
	self = [super init];
	if (self != nil) {
        handle = -1;
        
		stopMonitoringLock = [[NSLock alloc] init];
		devLock = [[NSLock alloc] init];
		ssLock = [[NSLock alloc] init];
		source1Voltage_V = 0;
		source1Current_A = 0;
		source2Voltage_V = 0;
		source2Current_A = 0;
		
		digitalOutput = 0;
		voltageOutput = MIN_OUT_VOLTAGE;
		currentOutput = MIN_OUT_VOLTAGE;
		
		shouldMonitorUpdate = YES;
		
        @try {
            [self resetDevice:nil];
            
            [self initAnalogOutChannel:nil];
            [self initControlInChannel:nil];
            [self initShutterDetectorChannel:nil];
            
        }
        @catch (NSException * e) {
            NSLog(@"XRayNIDAQ::initWithName: Caught %@: %@",
                  [e name],
                  [e reason]);
            
            @throw e;
        }
        @finally {
        }
        
        [NSThread detachNewThreadSelector:@selector(updateMonitorThread:)
                                 toTarget:self
                               withObject:nil];
	}
	return self;
}

- (void)dealloc {
    if (-1 != handle) {
        (void)LJM_eWriteName(handle, "LED_COMM", 0);
        (void)LJM_Close(handle);
    }
    
    shouldMonitorUpdate = NO;
}

- (void)setVoltageControl:(NSNumber *)percentOfMax {
	
	float percent = [percentOfMax floatValue];
	percent = percent > 1 ? 1 : percent;
	percent = percent < 0 ? 0 : percent;
	
	[devLock lock];
	voltageOutput = percent * MAX_OUT_VOLTAGE;
    NSArray<NSNumber *> *values = @[ @(voltageOutput), @(currentOutput) ];
	[devLock unlock];

    [stopMonitoringLock lock];
    [self setAnalogOut:values];
    [stopMonitoringLock unlock];
}

- (void)setCurrentControl:(NSNumber *)percentOfMax {
	float percent = [percentOfMax floatValue];
	percent = percent > 1 ? 1 : percent;
	percent = percent < 0 ? 0 : percent;
	
	[devLock lock];
	currentOutput = percent * MAX_OUT_VOLTAGE;
    NSArray<NSNumber *> *values = @[ @(voltageOutput), @(currentOutput) ];
	[devLock unlock];
	
    [stopMonitoringLock lock];
    [self setAnalogOut:values];
    [stopMonitoringLock unlock];
}

- (void)energizeSources:(NSNumber *)on {
	digitalOutput = [on boolValue] ? digitalOutput | 0x2 : digitalOutput & 0xFD;
    NSNumber *value = [NSNumber numberWithChar:digitalOutput];
	
    [stopMonitoringLock lock];
    [self setDigitalOutput:value];
    [stopMonitoringLock unlock];
}

- (void)activateDetectors:(NSNumber *)on {
	digitalOutput = [on boolValue] ? digitalOutput | 0x1 : digitalOutput & 0xFE;
    NSNumber *value = [NSNumber numberWithChar:digitalOutput];
    
    [stopMonitoringLock lock];
    [self setDigitalOutput:value];
    [stopMonitoringLock unlock];
}

- (void)setAnalogOut:(NSArray<NSNumber *> *)values {
    [devLock lock];
    
    const char * names[2] = { "DAC0", "DAC1" };
    double output[2] = { values[0].doubleValue, values[1].doubleValue };
    int errorAddress = -1;
    
    @try {
        [self checkError:LJM_eWriteNames(handle, 2, names, output, &errorAddress)];
    }
    @catch (NSException * e) {
        NSLog(@"XRayNIDAQ::setAnalogOut: Caught %@: %@",
              [e name],
              [e reason]);
        
        @throw e;
    }
    @finally {
    }
    
    [devLock unlock];
}

- (void)setDigitalOutput:(NSNumber *)value {
    uint8_t doData = [value shortValue];
	
	@try {
        [self checkError:LJM_eWriteName(handle, "DIO_STATE", doData)];
	}
	@catch (NSException * e) {
		NSLog(@"XRayNIDAQ::setDigitalOutput: Caught %@: %@", [e name], [e reason]);
		@throw e;
	}
	@finally {
	}
}


- (NSNumber *)source1Voltage {
	[ssLock lock];
	NSNumber *s0v = [[NSNumber alloc] initWithDouble:source1Voltage_V];
	[ssLock unlock];
	return s0v;
}

- (NSNumber *)source1Current {
	[ssLock lock];
	NSNumber *s0c = [[NSNumber alloc] initWithDouble:source1Current_A];
	[ssLock unlock];
	return s0c;
}

- (NSNumber *)source2Voltage {
	[ssLock lock];
	NSNumber *s1v = [[NSNumber alloc] initWithDouble:source2Voltage_V];
	[ssLock unlock];
	return s1v;	
}

- (NSNumber *)source2Current {
	[ssLock lock];
	NSNumber *s1c = [[NSNumber alloc] initWithDouble:source2Current_A];
	[ssLock unlock];
	return s1c;
}


// private methods
- (void)resetDevice:(id)arg {
    [devLock lock];
    
    [self checkError:LJM_Open(LJM_dtT7, LJM_ctUSB, "ANY", &handle)];
    [self checkError:LJM_eWriteName(handle, "IO_CONFIG_SET_CURRENT_TO_FACTORY", 1)];
    [self checkError:LJM_eWriteName(handle, "POWER_LED", 4)];  // Set LED operation to manual
    [self checkError:LJM_eWriteName(handle, "LED_STATUS", 1)];
    [self checkError:LJM_eWriteName(handle, "LED_COMM", 1)];
    
    [devLock unlock];
}

- (void)initAnalogOutChannel:(id)arg {
    [devLock lock];
    
    const char * names[2] = { "DAC0", "DAC1" };
    double output[2] = { voltageOutput, currentOutput };
    int errorAddress = -1;
    [self checkError:LJM_eWriteNames(handle, 2, names, output, &errorAddress)];
    
    [devLock unlock];
}


- (void)initControlInChannel:(id)arg {
    [devLock lock];
    
    // Set all AIN's to differential
    [self checkError:LJM_eWriteName(handle, "AIN_ALL_NEGATIVE_CH", 1)];
    
    // Set range of all AIN's to +/-10V
    [self checkError:LJM_eWriteName(handle, "AIN_ALL_RANGE", 10)];
    
    [devLock unlock];
}

- (void)initShutterDetectorChannel:(id)arg {
    [devLock lock];
    
    // Inhibit all DIO's except FIO0-1
    [self checkError:LJM_eWriteName(handle, "DIO_INHIBIT", ~((uint32_t)0x3))];
    
    // Configure FIO0-1 as outputs
    [self checkError:LJM_eWriteName(handle, "DIO_DIRECTION", 0x3)];
    
    // Set FIO0-1 low
    [self checkError:LJM_eWriteName(handle, "DIO_STATE", 0)];
    
    [devLock unlock];
}

- (void)updateMonitorThread:(id)arg {
	@autoreleasepool {
		while(shouldMonitorUpdate) {
			usleep(400000);
            [stopMonitoringLock lock];
            [self updateMonitor:nil];
            [stopMonitoringLock unlock];
		}
	}
}

- (void)updateMonitor:(id)arg {
    const char * names[4] = { "AIN0", "AIN2", "AIN4", "AIN6" };
    double data[4];
    int errorAddress = -1;
    
    [devLock lock];
    @try {
        [self checkError:LJM_eReadNames(handle, 4, names, data, &errorAddress)];
    }
    @catch (NSException * e) {
        NSLog(@"XRayNIDAQ::updateMonitor: Caught %@: %@", [e name], [e reason]);
        @throw e;
    }
    @finally {
    }
    [devLock unlock];
    
    [ssLock lock];
    source1Voltage_V = 5000*data[2];
    source1Current_A = 0.0001*data[3];
    source2Voltage_V = 5000*data[0];
    source2Current_A = 0.0001*data[1];
    [ssLock unlock];
}

- (void)checkError:(int)status {
    if (LJME_NOERROR != status) {
        char errBuff[LJM_MAX_NAME_SIZE];
        LJM_ErrorToString(status, errBuff);
        
        NSException *exception = [NSException exceptionWithName:@"LabJackException"
                                                         reason:@(errBuff)
                                                       userInfo:nil];
        
        @throw exception;
    }
}

@end
