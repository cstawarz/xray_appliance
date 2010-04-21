//
//  ProjectToCRV.h
//  XRayBox
//
//  Created by Ben Kennedy on 2/4/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaMxArray.h"


@interface ProjectToCRV : NSObject {

}

+ (void)projectElement:(NSString *)element_to_project_name
			   toFrame:(NSString *)frame_to_project_to
			  toBundle:(NSString *)current_bundle_path
			  usingCRV:(CocoaMxArray *)crv
			andOverlay:(CocoaMxArray *)overlay_crv
			andOpacity:(float)overlay_opacity;

+ (void)projectElement:(NSString *)element_to_project_name
			   toFrame:(NSString *)frame_to_project_to
			  toBundle:(NSString *)current_bundle_path
			  usingCRV:(CocoaMxArray *)crv;


@end
