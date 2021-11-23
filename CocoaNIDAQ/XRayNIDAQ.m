//
//  XRayNIDAQ.m
//  CocoaNIDAQ
//
//  Created by Ben Kennedy on 9/13/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import "XRayNIDAQ.h"


@interface XRayNIDAQ(PrivateMethods)
- (void)resetDevice:(id)arg;
- (void)initAnalogOutChannel:(id)arg;
- (void)initControlInChannel:(id)arg;
- (void)initShutterDetectorChannel:(id)arg;
- (void)setAnalogOut:(NSArray<NSNumber *> *)values;
- (void)setDigitalOutput:(NSNumber *)value;
- (void)checkError:(int32)errorValue;
- (void)updateMonitorThread:(id)arg;
- (void)updateMonitor:(id)arg;
@end

@implementation XRayNIDAQ
- (id)initWithName:(NSString *)devName {
	self = [super init];
	if (self != nil) {
		deviceName = [[NSString alloc] initWithString:devName];
		
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
        
        nidaqAPIQueue = dispatch_queue_create_with_target(NULL,
                                                          DISPATCH_QUEUE_SERIAL,
                                                          dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0));
		
        dispatch_async(nidaqAPIQueue, ^{
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
        });
	}
	return self;
}

- (void)dealloc {
    dispatch_sync(nidaqAPIQueue, ^{
        [self resetDevice:nil];
    });
    
	shouldMonitorUpdate = NO;
    
    nidaqAPIQueue = nil;

}

- (void)setVoltageControl:(NSNumber *)percentOfMax {
	
	float percent = [percentOfMax floatValue];
	percent = percent > 1 ? 1 : percent;
	percent = percent < 0 ? 0 : percent;
	
	[devLock lock];
	voltageOutput = percent * MAX_OUT_VOLTAGE;
    NSArray<NSNumber *> *values = @[ @(voltageOutput), @(currentOutput) ];
	[devLock unlock];

    dispatch_async(nidaqAPIQueue, ^{
        [stopMonitoringLock lock];
        [self setAnalogOut:values];
        [stopMonitoringLock unlock];
    });
}

- (void)setCurrentControl:(NSNumber *)percentOfMax {
	float percent = [percentOfMax floatValue];
	percent = percent > 1 ? 1 : percent;
	percent = percent < 0 ? 0 : percent;
	
	[devLock lock];
	currentOutput = percent * MAX_OUT_VOLTAGE;
    NSArray<NSNumber *> *values = @[ @(voltageOutput), @(currentOutput) ];
	[devLock unlock];
	
    dispatch_async(nidaqAPIQueue, ^{
        [stopMonitoringLock lock];
        [self setAnalogOut:values];
        [stopMonitoringLock unlock];
    });
}

- (void)energizeSources:(NSNumber *)on {
	digitalOutput = [on boolValue] ? digitalOutput | 0x2 : digitalOutput & 0xFD;
    NSNumber *value = [NSNumber numberWithChar:digitalOutput];
	
    dispatch_async(nidaqAPIQueue, ^{
        [stopMonitoringLock lock];
        [self setDigitalOutput:value];
        [stopMonitoringLock unlock];
    });
}

- (void)activateDetectors:(NSNumber *)on {
	digitalOutput = [on boolValue] ? digitalOutput | 0x1 : digitalOutput & 0xFE;
    NSNumber *value = [NSNumber numberWithChar:digitalOutput];
    
    dispatch_async(nidaqAPIQueue, ^{
        [stopMonitoringLock lock];
        [self setDigitalOutput:value];
        [stopMonitoringLock unlock];
    });
}

- (void)setAnalogOut:(NSArray<NSNumber *> *)values {
	[devLock lock];
	int32 written;
	float64 output[2];
    output[0] = values[0].doubleValue;
    output[1] = values[1].doubleValue;
	
	@try {
		[self checkError:DAQmxBaseWriteAnalogF64(analogOutHandle,
												 1,
												 0,
												 1,
												 DAQmx_Val_GroupByChannel,
												 output,
												 &written,
												 NULL)];
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
	int32 written;
	uInt8 doData = [value shortValue];
	
	@try {
		[self checkError:DAQmxBaseWriteDigitalU8(detectorShutterControlHandle,
												 1,
												 FALSE,
												 1.0,
												 DAQmx_Val_GroupByChannel,
												 &doData,
												 &written,
												 NULL)];
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
	[self checkError:DAQmxBaseStopTask(analogOutHandle)];
	[self checkError:DAQmxBaseStopTask(controlInHandle)];
	[self checkError:DAQmxBaseStopTask(detectorShutterControlHandle)];
	
	[self checkError:DAQmxBaseCreateTask("",&analogOutHandle)];
	[self checkError:DAQmxBaseCreateTask("",&controlInHandle)];
	[self checkError:DAQmxBaseCreateTask("",&detectorShutterControlHandle)];
	
	[self checkError:DAQmxBaseClearTask(analogOutHandle)];
	[self checkError:DAQmxBaseClearTask(controlInHandle)];
	[self checkError:DAQmxBaseClearTask(detectorShutterControlHandle)];
	
//	[self checkError:DAQmxBaseResetDevice([deviceName cStringUsingEncoding:NSASCIIStringEncoding])];
	[devLock unlock];
}

- (void)initAnalogOutChannel:(id)arg {
	[devLock lock];
	
	[self checkError:DAQmxBaseCreateTask("",&analogOutHandle)];
	NSString *analogOutName = [deviceName stringByAppendingString:@"/ao0:1"];
	[self checkError:DAQmxBaseCreateAOVoltageChan(analogOutHandle,
												  [analogOutName cStringUsingEncoding:NSASCIIStringEncoding],
												  "",
												  MIN_OUT_VOLTAGE,
												  MAX_OUT_VOLTAGE,
												  DAQmx_Val_Volts,
												  NULL)];
	[self checkError:DAQmxBaseStartTask(analogOutHandle)];
	
	int32 written;
	float64 output[2];
	output[0] = voltageOutput;
	output[1] = currentOutput;
	
	[self checkError:DAQmxBaseWriteAnalogF64(analogOutHandle,
											 1,
											 0,
											 1,
											 DAQmx_Val_GroupByChannel,
											 output,
											 &written,
											 NULL)];
	[devLock unlock];
}


- (void)initControlInChannel:(id)arg {
	[devLock lock];
	[self checkError:DAQmxBaseCreateTask("",&controlInHandle)];
	NSString *controlInName = [deviceName stringByAppendingString:@"/ai0:3"];
	[self checkError:DAQmxBaseCreateAIVoltageChan(controlInHandle,
												  [controlInName cStringUsingEncoding:NSASCIIStringEncoding],
												  "",
												  DAQmx_Val_Diff,
												  MIN_IN_VOLTAGE,
												  MAX_IN_VOLTAGE,
												  DAQmx_Val_Volts,
												  NULL)];
	[self checkError:DAQmxBaseStartTask(controlInHandle)];
	[devLock unlock];
}

- (void)initShutterDetectorChannel:(id)arg {
	[devLock lock];
	[self checkError:DAQmxBaseCreateTask("",&detectorShutterControlHandle)];
	NSString *detectorShutterName = [deviceName stringByAppendingString:@"/port0"];
	[self checkError:DAQmxBaseCreateDOChan(detectorShutterControlHandle,
										   [detectorShutterName cStringUsingEncoding:NSASCIIStringEncoding],
										   "",
										   DAQmx_Val_ChanForAllLines)];
	[self checkError:DAQmxBaseStartTask(detectorShutterControlHandle)];
	
	int32 written;
	uInt8 doData = LOGIC_0;
	
	[self checkError:DAQmxBaseWriteDigitalU8(detectorShutterControlHandle,
											 1,
											 FALSE,
											 1.0,
											 DAQmx_Val_GroupByChannel,
											 &doData,
											 &written,
											 NULL)];
	[devLock unlock];
}

- (void)updateMonitorThread:(id)arg {
	@autoreleasepool {
		while(shouldMonitorUpdate) {
			usleep(400000);
        dispatch_sync(nidaqAPIQueue, ^{
            [stopMonitoringLock lock];
            [self updateMonitor:nil];
            [stopMonitoringLock unlock];
        });
		}
	}
}

- (void)updateMonitor:(id)arg {
		int32 pointsRead;
		float64 data[4];
		
		[devLock lock];
		@try {
			[self checkError:DAQmxBaseReadAnalogF64(controlInHandle,
													DAQmx_Val_Auto,
													1.0,
													DAQmx_Val_GroupByChannel,
													data,
													4,
													&pointsRead,
													NULL)];	
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

- (void)checkError:(int32)status {
	if(status) { 
		int32 bufferSize = DAQmxBaseGetExtendedErrorInfo(NULL,0);
		char *errBuff=malloc(bufferSize); 
		DAQmxBaseGetExtendedErrorInfo(errBuff,bufferSize); 
        NSString *errorString = [[NSString alloc] initWithBytes:errBuff
                                                         length:bufferSize
                                                       encoding:NSASCIIStringEncoding];
		free(errBuff);
		
		NSException *exception = [NSException exceptionWithName:@"NIDAQException"
														 reason:errorString  
													   userInfo:nil];
		
		@throw exception;
	}
}

@end
