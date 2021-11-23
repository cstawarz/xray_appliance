//
//  XrayObject.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayObject.h"


@implementation XrayObject

- (id)initWithName:(NSString *)_name
	 andVisibility:(NSString *)_visibility {
	self = [super init];
	if (self != nil) {
		name = [_name copy];
		visibility = [_visibility copy];
	}
	return self;
}


- (NSString *)name {return name;}
- (PlotableXrayObject *)plotableObject {return po;}
//@synthesize name=name, plotableObject=po;

//@synthesize visibility=visibility;
- (NSString *)visibility {return visibility;}

- (BOOL)isXrayVisible {
	return [[visibility lowercaseString] rangeOfString:@"x"].location != NSNotFound;
}



- (id)copyWithZone:(NSZone *)zone {
	[NSException raise:NSInternalInconsistencyException
				format:@"trying to copy an abstract object"];
	return nil;
}

@end
