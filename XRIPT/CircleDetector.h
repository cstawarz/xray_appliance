//
//  CircleDetector.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GlobalMATLABEngine.h"



@interface CircleDetector : NSObject {

}

+ (NSPoint)circleCenterOnImage:(NSData *)image
				usingSeedPoint:(NSPoint)seed
				 andWindowSize:(unsigned int)window_size;

@end
