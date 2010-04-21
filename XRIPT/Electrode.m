//
//  Electrode.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "Electrode.h"
#import "ElectrodePlotableObject.h"

@implementation Electrode

- (id) initWithName:(NSString *)_name {
	self = [super initWithName:_name andVisibility:@"x"];
	if(self != nil) {
		po = [[ElectrodePlotableObject alloc] init];
	}
	return self;
}

- (void)dealloc {
	[po release];
	[super dealloc];
}

+ (id)electrodeWithName:(NSString *)_name {
	return [[[self alloc] initWithName:_name] autorelease];	
}

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone: zone] initWithName:name];
}

- (XrayObjectType)type {
	return ELECTRODE;
}


@end
