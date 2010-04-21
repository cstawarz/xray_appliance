//
//  ApplicationController.h
//  XRayBox
//
//  Created by Ben Kennedy on 2/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "PreferencesWindowController.h"
#import "XrayImageWindowController.h"
#import "FiducialWindowController.h"
#import "NewXrayObjectWindowController.h"
#import "CalibrationWindowController.h"
#import "OperationsWindowController.h"

#import "XrayDataModel.h"

#import "CocoaShadoCam/ShadoCam.h"
#import "CocoaNIDAQ/XRayNidaq.h"


@interface ApplicationController : NSObject {
	MainWindowController *main_window_controller;
	PreferencesWindowController *preferences_window_controller;
	XrayImageWindowController *detector_1_image_window_controller;
	XrayImageWindowController *detector_2_image_window_controller;
	FiducialWindowController *fiducial_window_controller;
	NewXrayObjectWindowController *new_xray_object_window_controller;
	CalibrationWindowController *calibration_window_controller;
	OperationsWindowController *operations_window_controller;
	
	ShadoCam *detector_1;
	ShadoCam *detector_2;
	
	XRayNIDAQ *daq;
	
	NSMutableArray *bundles;
	XrayDataModel *model;
	
}

- (XrayDataModel *)model;
// @property (readonly) XrayDataModel *model;

- (IBAction)openSettingsWindow:(id)sender;
- (IBAction)openCalibrationWindow:(id)sender;
- (IBAction)openBundle:(id)sender;

@end

@interface ApplicationController (DelegateMethods) 
- (void)takeXray:(id)sender;
- (void)primeXray:(id)sender;
- (void)openNewXrayObjectWindow:(id)sender;
- (void)setChanged:(NSString *)new_set_name;
@end
