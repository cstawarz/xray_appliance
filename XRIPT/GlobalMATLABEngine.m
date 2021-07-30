//
//  GlobalMATLABEngine.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "GlobalMATLABEngine.h"
#import "engine.h"


static GlobalMATLABEngine *global_MATLAB_engine;

@implementation GlobalMATLABEngine

- (id) init {
	self = [super init];
	if (self != nil) {
		engine_lock = [[NSLock alloc] init];
        NSString *matlabStartupCommand = [NSString stringWithFormat:@"%s/bin/matlab -nosplash -%s", MATLAB_PATH, MATLAB_ARCH];
		matlab_engine = engOpen(matlabStartupCommand.UTF8String);
		engSetVisible(matlab_engine, 0);
		engOutputBuffer(matlab_engine, NULL, 0);
		
		NSString *resource_directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MATLAB"];
		NSString *interface_directory = [resource_directory stringByAppendingPathComponent:@"MATLAB_interface_tools"];
		NSString *home_directory = [resource_directory stringByAppendingPathComponent:@"XRayLocalizationCode/packagedMatlabCode"];
		
		
		engEvalString(matlab_engine, 
					  [[NSString stringWithFormat:@"addpath('%@')", resource_directory] cStringUsingEncoding:NSASCIIStringEncoding]);
		engEvalString(matlab_engine, 
					  [[NSString stringWithFormat:@"addpath('%@')", interface_directory] cStringUsingEncoding:NSASCIIStringEncoding]);
		engEvalString(matlab_engine, 
					  [[NSString stringWithFormat:@"addpath('%@')", home_directory] cStringUsingEncoding:NSASCIIStringEncoding]);
		engEvalString(matlab_engine, 
					  [[NSString stringWithFormat:@"homeDirectory='%@'", home_directory] cStringUsingEncoding:NSASCIIStringEncoding]);
		engEvalString(matlab_engine, "globals");
	}
	return self;
}

- (void)dealloc {
	engClose(matlab_engine);
	[engine_lock release];
	[super dealloc];
}

+ (GlobalMATLABEngine *)lockedEngine {
    @synchronized(self) {
        if (global_MATLAB_engine == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
	[global_MATLAB_engine lock];
    return global_MATLAB_engine;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (global_MATLAB_engine == nil) {
            global_MATLAB_engine = [super allocWithZone:zone];
            return global_MATLAB_engine;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void)setVariable:(CocoaMxArray *)value
				 as:(NSString *)variable_name {
	engPutVariable(matlab_engine, 
				   [variable_name cStringUsingEncoding:NSASCIIStringEncoding], 
				   [value array]);
}

- (CocoaMxArray *)getVariableValue:(NSString *)variable_name {	
	mxArray *value = engGetVariable(matlab_engine,
									[variable_name cStringUsingEncoding:NSASCIIStringEncoding]);
	
	CocoaMxArray *return_value = [CocoaMxArray arrayWithMxArray:value];
	mxDestroyArray(value);
	return return_value;
}

- (void)evalString:(NSString *)cmd {
	engEvalString(matlab_engine, 
				  [cmd cStringUsingEncoding:NSASCIIStringEncoding]);

}

- (void)lock {
	[engine_lock lock];	
}

- (void)unlock {
	[engine_lock unlock];	
}

- (NSPoint)MATLABPointFromXrayPoint:(NSPoint)cocoa_point 
					 usingImageSize:(NSSize)image_size {
	return NSMakePoint(cocoa_point.x + 0.5,
					   (image_size.height-cocoa_point.y)+0.5);
}

- (NSPoint)xrayPointFromMATLABPoint:(NSPoint)MATLAB_point
					 usingImageSize:(NSSize)image_size {
	return NSMakePoint(MATLAB_point.x - 0.5,
					   (image_size.height-MATLAB_point.y)-0.5);
}

@end
