//
//  Electrode.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayObject.h"

@interface Electrode : XrayObject {
	
}

- (id)initWithName:(NSString *)_name;
+ (id)electrodeWithName:(NSString *)_name;

@end
