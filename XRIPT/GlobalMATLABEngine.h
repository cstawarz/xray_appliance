//
//  GlobalMATLABEngine.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "engine.h"
#import "CocoaMxArray.h"

//#ifdef __ppc__
//typedef int mwSize;
//#endif


@interface GlobalMATLABEngine : NSObject {
	Engine *matlab_engine;
	NSLock *engine_lock;
}

- (id) init;
- (void)dealloc;
+ (GlobalMATLABEngine *)lockedEngine;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (void)evalString:(NSString *)cmd;
- (void)setVariable:(CocoaMxArray *)value
				 as:(NSString *)variable_name;
- (void)lock;
- (void)unlock;

- (CocoaMxArray *)getVariableValue:(NSString *)variable_name;

- (NSPoint)MATLABPointFromXrayPoint:(NSPoint)cocoa_point 
					 usingImageSize:(NSSize)image_size;

- (NSPoint)xrayPointFromMATLABPoint:(NSPoint)MATLAB_point
					 usingImageSize:(NSSize)image_size;

@end
