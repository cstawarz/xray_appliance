//
//  PreferencesWindowController.h
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayPreferences.h"

@interface PreferencesWindowController : NSWindowController {
	XrayPreferences *preferences;
	
	IBOutlet NSPopUpButton *max_voltage_popup_button;
	IBOutlet NSPopUpButton *max_current_popup_button;
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andPreferences:(XrayPreferences *)new_preferences;

- (IBAction)browseForSaveLocationDir:(id)sender;
- (IBAction)maxCurrentChanged:(id)sender;
- (IBAction)maxVoltageChanged:(id)sender;

- (XrayPreferences *)preferences;
- (void)setPreferences:(XrayPreferences *)new_preferences;

- (NSTimeInterval)detectorLag;
- (void)setDetectorLag:(NSTimeInterval)new_detector_lag;

@end
