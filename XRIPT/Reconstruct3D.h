//
//  Reconstruct3D.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/28/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XRayBundle.h"
#import "Calibration.h"

@interface Reconstruct3D : NSObject {

}

+ (BOOL)reconstructBundle:(NSString *)bundle_path;
+ (BOOL)isReconstructionAvailable:(NSString *)bundle_path;

@end
