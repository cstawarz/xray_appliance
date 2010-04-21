//
//  XrayObject.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlotableXrayObject.h"

typedef enum tagXrayObjectType{ FIDUCIAL, ELECTRODE, UNDEFINED_TYPE } XrayObjectType;

@interface XrayObject : NSObject <NSCopying> {
	NSString *name;
	NSString *visibility;
	PlotableXrayObject *po; // must be allocated and deallocated from concrete classes
}

- (id)initWithName:(NSString *)_name
	 andVisibility:(NSString *)_visibility;

- (NSString *)name;
- (PlotableXrayObject *)plotableObject;
- (NSString *)visibility;
- (BOOL)isXrayVisible;

@end


@interface XrayObject (AbstractMethods)
- (XrayObjectType)type;
@end