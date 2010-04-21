//
//  FiducialPlotableObject.m
//  XRIPT
//
//  Created by bkennedy on 3/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FiducialPlotableObject.h"
#define PLUS_ARM_SIZE 10

@implementation FiducialPlotableObject

- (NSBezierPath *)pathOnDetector:(Detector)detector
					  withBounds:(NSRect)bounds
					 imageRegion:(NSRect)image_region
						viewSize:(NSSize)view_size 
	   andCenterFinderWindowSize:(NSSize)center_finder_window_size {
	
	NSPoint center = [self pointForDetector:detector];
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	if(center.x > 0 && center.y > 0) {
		float image_hw_ratio = image_region.size.height/image_region.size.width;
		float actual_hw_ratio = view_size.height/view_size.width;
		
		float scale_factor;
		
		if(image_hw_ratio > actual_hw_ratio) {
			// view is wider than image ... limited by height
			scale_factor = view_size.height/image_region.size.height;
		} else {
			// view is taller than image
			scale_factor = view_size.width/image_region.size.width;
		}
		
		float scaled_plus_size = PLUS_ARM_SIZE*scale_factor;
		float scaled_window_size_height = center_finder_window_size.height*scale_factor/2;
		float scaled_window_size_width = center_finder_window_size.width*scale_factor/2;
		
		
		NSPoint center_percentage = NSMakePoint((center.x-image_region.origin.x)/image_region.size.width, 
												(center.y-image_region.origin.y)/image_region.size.height);
		NSPoint scaled_center = NSMakePoint((center_percentage.x*bounds.size.width) + bounds.origin.x,
											(center_percentage.y*bounds.size.height) + bounds.origin.y);
		[path moveToPoint:NSMakePoint(scaled_center.x, scaled_center.y-scaled_plus_size)];
		[path lineToPoint:NSMakePoint(scaled_center.x, scaled_center.y+scaled_plus_size)];
		[path moveToPoint:NSMakePoint(scaled_center.x-scaled_plus_size, scaled_center.y)];
		[path lineToPoint:NSMakePoint(scaled_center.x+scaled_plus_size, scaled_center.y)];
		
		// draw the window around the point
		[path moveToPoint:NSMakePoint(scaled_center.x+scaled_window_size_width, scaled_center.y+scaled_window_size_height)];
		[path lineToPoint:NSMakePoint(scaled_center.x-scaled_window_size_width, scaled_center.y+scaled_window_size_height)];
		[path lineToPoint:NSMakePoint(scaled_center.x-scaled_window_size_width, scaled_center.y-scaled_window_size_height)];
		[path lineToPoint:NSMakePoint(scaled_center.x+scaled_window_size_width, scaled_center.y-scaled_window_size_height)];
		[path lineToPoint:NSMakePoint(scaled_center.x+scaled_window_size_width, scaled_center.y+scaled_window_size_height)];
	}
	
	return path;
}

@end
