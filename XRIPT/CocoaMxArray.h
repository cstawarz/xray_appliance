//
//  CocoaMxArray.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "mat.h"

@interface CocoaMxArray : NSObject {
	mxArray *array;
}

- (id)initWithMxArray:(mxArray *)new_array;
+ (id)arrayWithMxArray:(mxArray *)new_array;
- (void) dealloc;
- (mxArray *)array;

@end
