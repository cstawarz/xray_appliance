//
//  XrayDataModel.h
//  XRIPT
//
//  Created by bkennedy on 3/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayPreferences.h"
#import "XrayObjects.h"
#import "FFORManager.h"
#import "XrayBundle.h"


@interface XrayDataModel : NSObject {
	BOOL not_primed;
	BOOL not_operating;
	
	XrayPreferences *preferences;
	XrayObjects *xray_objects;
	FFORManager *ffor_manager;
	
	NSString *status_message;
	
	XrayBundle *current_bundle;
}

- (XrayObjects *)xrayObjects;
- (XrayPreferences *)preferences;
- (FFORManager *)fforManager;
- (BOOL)xrayNotPrimed;
- (void)setXrayNotPrimed:(BOOL)new_xray_not_primed;
- (BOOL)xrayNotOperating;
- (void)setXrayNotOperating:(BOOL)new_xray_not_operating;
- (NSString *)statusMessage;
- (void)setStatusMessage:(NSString *)new_status_message;
- (XrayBundle *)currentBundle;
- (void)setCurrentBundle:(XrayBundle *)currentBundle;

//@property (readonly) XrayObjects *xrayObjects;
//@property (readonly) XrayPreferences *preferences;
//@property (readonly) FFORManager *fforManager;
//@property (readwrite) BOOL xrayNotPrimed, xrayNotOperating;
//@property (readwrite, copy) NSString *statusMessage;
//@property (readwrite, assign) XrayBundle *currentBundle;

@end
