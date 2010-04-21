//
//  PlotableXrayObject.m
//  XRIPT
//
//  Created by bkennedy on 3/19/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "PlotableXrayObject.h"


@implementation PlotableXrayObject

- (id)init {
	self = [super init];
	if(self) {
		points = [[NSMutableDictionary alloc] init];
		color = [[NSColor blueColor] copy];
	}
	return self;
}

- (void)dealloc {
	[points release];
	[color release];
	[super dealloc];
}

//@synthesize color=color;
- (NSColor *)color {return color;}
- (void)setColor:(NSColor *)new_color {
	[color release];
	color = [new_color copy];
}


- (void)setPoint:(NSPoint)point forDetector:(Detector)detector {
	[points setObject:[NSValue valueWithPoint:point] 
			   forKey:[NSNumber numberWithInt:detector]];
}


- (NSPoint)pointForDetector:(Detector)detector {
	NSValue *point = [points objectForKey:[NSNumber numberWithInt:detector]];
	return (point == nil) ? NSMakePoint(-1,-1) : [point pointValue];
}

@end
