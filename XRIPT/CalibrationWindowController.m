//
//  CalibrationWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/23/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CalibrationWindowController.h"
#import "Calibration.h"

#define XRIPT_CALIBRATION @"XRIPT - calibration path name"

@implementation CalibrationWindowController

- initWithPath:(NSString *)new_path {
	return [super initWithWindowNibName:@"CalibrationWindow"];
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andPreferences:(XrayPreferences *)new_preferences {
	self = [super initWithWindowNibName:nib_name];
	if(self != nil) {
		preferences = [new_preferences retain];
	}
	return self;
}

- (void)dealloc {
	[preferences release];
	[super dealloc];
}

- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:@"XRIPT - CalibrationWindow"];
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	if([ud stringForKey:XRIPT_CALIBRATION] != nil) {
		Calibration *calibration = [[Calibration alloc] initWithFile:[ud stringForKey:XRIPT_CALIBRATION]];
		[preferences setCalibration:calibration];
	}
	
}

- (XrayPreferences *)preferences {return preferences;}
- (void)setPreferences:(XrayPreferences *)new_preferences {
	[preferences release];
	preferences = [new_preferences retain];
}

- (IBAction)useCalibration:(id)sender {
	NSOpenPanel * op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:YES];
	// it is important that you never allow multiple files to be selected!
	[op setAllowsMultipleSelection:NO];
	
	
	
	int bp = [op runModalForTypes:[NSArray arrayWithObjects:@"mat", nil]];
	if(bp == NSModalResponseOK) {
		NSArray * fn = [op filenames];
		NSEnumerator * fileEnum = [fn objectEnumerator];
		NSString * filename;
		while(filename = [fileEnum nextObject]) {
			Calibration *new_calibration = [Calibration calibrationWithFile:filename];
			
			if(new_calibration) {
				[preferences setCalibration:new_calibration];
				[[NSUserDefaults standardUserDefaults] setObject:filename forKey:XRIPT_CALIBRATION];
			} else {
				[preferences setCalibrationMessage:@"Invalid calibration bundle"];				
			}
		}
	}
}

@end
