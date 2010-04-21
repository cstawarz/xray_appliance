//
//  PlotableXrayObject.h
//  XRIPT
//
//  Created by bkennedy on 3/19/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayConstants.h"

@interface PlotableXrayObject : NSObject {
	NSMutableDictionary *points;
	NSColor *color;
}

- (NSColor *)color;
- (void)setColor:(NSColor *)new_color;

- (void)setPoint:(NSPoint)point forDetector:(Detector)detector;
- (NSPoint)pointForDetector:(Detector)detector;

@end

@interface PlotableXrayObject (AbstractMethods)
- (NSBezierPath *)pathOnDetector:(Detector)detector
					  withBounds:(NSRect)bounds
					 imageRegion:(NSRect)image_region
						viewSize:(NSSize)view_size 
	   andCenterFinderWindowSize:(NSSize)center_finder_window_size;
@end
