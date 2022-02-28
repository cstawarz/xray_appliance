//
//  XRayNIDAQ.h
//  CocoaNIDAQ
//
//  Created by Ben Kennedy on 9/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XRayNIDAQ : NSObject

- (void)setVoltageControl:(NSNumber *)percentOfMax;
- (void)setCurrentControl:(NSNumber *)percentOfMax;
- (void)energizeSources:(NSNumber *)on;
- (void)activateDetectors:(NSNumber *)on;
- (NSNumber *)source1Voltage;
- (NSNumber *)source2Voltage;
- (NSNumber *)source1Current;
- (NSNumber *)source2Current;

@end
