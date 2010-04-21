//
//  XrayBundleMATLABInterface.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XrayBundleMATLABInterface : NSObject {

}

+ (void)write:(NSArray *)xray_xray_objects
	 toBundle:(NSString *)bundle_path;

+ (NSArray *)xrayElementsFromBundle:(NSString *)bundle_path;

@end
