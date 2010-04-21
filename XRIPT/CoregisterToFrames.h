//
//  CoregisterToFrames.h
//  XRayBox
//
//  Created by Ben Kennedy on 2/4/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CoregisterToFrames : NSObject {
}
+ (BOOL)coregisterBundle:(NSString *)bundle_path
			 usingFrames:(NSArray *)frames_to_use;
+ (BOOL)isBundleCoregistered:(NSString *)bundle_path toFrames:(NSArray *)frames;

@end
