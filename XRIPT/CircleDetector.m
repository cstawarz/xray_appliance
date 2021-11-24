//
//  CircleDetector.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CircleDetector.h"
#import "GlobalMATLABEngine.h"
#import "CocoaMxArray.h"

@interface CircleDetector (PrivateMethods)
+ (CocoaMxArray *)convertImageToMxArray:(NSData *)image;
@end

@implementation CircleDetector

+ (NSPoint)circleCenterOnImage:(NSData *)image
				usingSeedPoint:(NSPoint)seed
				 andWindowSize:(unsigned int)window_size {
	
	if(seed.x <= 0 || seed.y <= 0) {
		return NSMakePoint(-1, -1);
	}
	
	// do this first because it needs the MATLAB engine and it locks it
	CocoaMxArray *image_array = [self convertImageToMxArray:image];
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	
	NSImage *temp_image = [[NSImage alloc] initWithData:image];
	
	NSPoint converted_seed_point = [engine MATLABPointFromXrayPoint:seed
													 usingImageSize:[temp_image size]];
	
	NSString *image_variable_name = @"image";
	NSString *x_output_variable_name = @"x_out";
	NSString *y_output_variable_name = @"y_out";
	
	[engine setVariable:image_array
					 as:image_variable_name];

	NSString *find_center_command = [NSString stringWithFormat:@"[%@,%@] = fiducialFinder1(%@,%f,%f, %u);",
		x_output_variable_name,
		y_output_variable_name,
		image_variable_name,
		converted_seed_point.x,
		converted_seed_point.y,
		window_size];

	[engine evalString:find_center_command];

	CocoaMxArray *center_x = [engine getVariableValue:x_output_variable_name];
	CocoaMxArray *center_y = [engine getVariableValue:y_output_variable_name];
	[engine unlock];
	
	NSPoint new_center = NSMakePoint(mxGetScalar([center_x array]), 
									 mxGetScalar([center_y array]));


	if(new_center.x <= 0 || new_center.y <= 0) {
		return NSMakePoint(-1, -1);
	} else {
		return [engine xrayPointFromMATLABPoint:new_center
								 usingImageSize:[temp_image size]];
	}
}

// private methods
+ (CocoaMxArray *)convertImageToMxArray:(NSData *)image {
	NSString *temp_image_file = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"XRayBox_tif%d.tif", rand()]];
	[image writeToFile:temp_image_file atomically:YES];
	
	NSString *output_image_variable_name = @"image";
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	
	NSString *imread_command = [NSString stringWithFormat:@"%@ = imread('%@');",
		output_image_variable_name, 
		temp_image_file];
	
	[engine evalString:imread_command];
	
	CocoaMxArray *output_image_return = [engine getVariableValue:output_image_variable_name];
	[engine unlock];


	NSFileManager *dfm = [NSFileManager defaultManager];
	if(![dfm removeFileAtPath:temp_image_file
					  handler:nil]) {
		[NSException raise:NSInternalInconsistencyException
					format:@"[CircleDetector convertImageToMxArray:] can't delete file: %@",
			temp_image_file];
	}
	
	return output_image_return;
}

@end
