//
//  CalibrationWindowController.h
//  XRIPT
//
//  Created by bkennedy on 3/23/08.
//  Copyright 2008 MIT. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "XrayPreferences.h"

@interface CalibrationWindowController : NSWindowController {
	XrayPreferences *preferences;
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andPreferences:(XrayPreferences *)new_preferences;

- (XrayPreferences *)preferences;
- (void)setPreferences:(XrayPreferences *)new_preferences;

- (IBAction)useCalibration:(id)sender;

@end
