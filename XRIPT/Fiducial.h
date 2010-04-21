//
//  Fiducial.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayObject.h"

@interface Fiducial : XrayObject {
}

- (id)initWithName:(NSString *)_name;
- (id)initWithName:(NSString *)_name 
	 andVisibility:(NSString *)_visibility;
+ (id)fiducialWithName:(NSString *)name;
+ (id)fiducialWithName:(NSString *)name 
		 andVisibility:(NSString *)_visibility;

@end
