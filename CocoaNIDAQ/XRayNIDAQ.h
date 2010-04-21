//
//  XRayNIDAQ.h
//  CocoaNIDAQ
//
//  Created by Ben Kennedy on 9/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NIDAQmxBase.h"

#define MIN_OUT_VOLTAGE 0.0
#define MAX_OUT_VOLTAGE 5.0

#define MIN_IN_VOLTAGE 0.0
#define MAX_IN_VOLTAGE 10.0

#define LOGIC_0 0
#define LOGIC_1 1

@interface XRayNIDAQ : NSObject {
	NSString *deviceName;
	
	TaskHandle analogOutHandle;
	TaskHandle controlInHandle;
	TaskHandle detectorShutterControlHandle;	
	
	uInt8 digitalOutput;
	float64 voltageOutput;
	float64 currentOutput;
	
	NSLock *devLock;
	NSLock *stopMonitoringLock;
	NSLock *ssLock;
	BOOL shouldMonitorUpdate;

	float64 source1Current_A;
	float64 source1Voltage_V;
	float64 source2Current_A;
	float64 source2Voltage_V;
}


- (id)initWithName:(NSString *)devName;
- (void)dealloc;		
- (void)setVoltageControl:(NSNumber *)percentOfMax;
- (void)setCurrentControl:(NSNumber *)percentOfMax;
- (void)energizeSources:(NSNumber *)on;
- (void)activateDetectors:(NSNumber *)on;
- (NSNumber *)source1Voltage;
- (NSNumber *)source2Voltage;
- (NSNumber *)source1Current;
- (NSNumber *)source2Current;

@end
