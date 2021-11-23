//
//  Fiducial.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "Fiducial.h"
#import "FiducialPlotableObject.h"

@implementation Fiducial
- (id)initWithName:(NSString *)_name {
	return [self initWithName:_name andVisibility:@""];
}
- (id)initWithName:(NSString *)_name 
	 andVisibility:(NSString *)_visibility {
	self = [super initWithName:_name andVisibility:_visibility];
	if (self != nil) {
		po = [[FiducialPlotableObject alloc] init];
	}
	return self;	
}

+ (id)fiducialWithName:(NSString *)_name {
	return [[self alloc] initWithName:_name];	
}

+ (id)fiducialWithName:(NSString *)_name 
		 andVisibility:(NSString *)_visibility {
	return [[self alloc] initWithName:_name andVisibility:_visibility];	
}


- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone: zone] initWithName:name andVisibility:visibility];
}


- (XrayObjectType)type {
	return FIDUCIAL;
}


@end
