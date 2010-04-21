//
//  CocoaMxArray.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CocoaMxArray.h"


@implementation CocoaMxArray

- (id) initWithMxArray:(mxArray *)new_array {
	self = [super init];
	if (self != nil) {
		if(new_array != NULL) {
			array = mxDuplicateArray(new_array);
		} else { 
			[NSException raise:NSInternalInconsistencyException
						format:@"trying to create ne CocoaMxArray with null mxArray"];
		}
	}
	return self;
}

+ (id)arrayWithMxArray:(mxArray *)new_array {	
	return [[[self alloc] initWithMxArray:new_array] autorelease];
}

- (void) dealloc {
	mxDestroyArray(array);
	[super dealloc];
}

- (mxArray *)array {
	return array;
}

@end
