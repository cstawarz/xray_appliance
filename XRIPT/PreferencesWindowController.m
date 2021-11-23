//
//  PreferencesWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "XrayConstants.h"


@implementation PreferencesWindowController

- initWithPath:(NSString *)new_path {
	return [super initWithWindowNibName:@"PreferencesWindow"];
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andPreferences:(XrayPreferences *)new_preferences {
	self = [super initWithWindowNibName:nib_name];
	if(self != nil) {
		preferences = new_preferences;
	}
	return self;
}


- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:@"XRIPT - PreferencesWindow"];
	
	// select the proper value for the max current and voltage
	if ([[self preferences] maxVoltage] >= MAX_XRAY_VOLTAGE || [[self preferences] maxVoltage] <= MIN_XRAY_VOLTAGE) {
		[max_voltage_popup_button selectItemAtIndex:0];
	} else {
		int voltage_index = ([max_voltage_popup_button numberOfItems] - round([[self preferences] maxVoltage]/10000)) - 1;
		[max_voltage_popup_button selectItemAtIndex:voltage_index];
	}
	[self maxVoltageChanged:self];
	
	if ([[self preferences] maxCurrent] >= MAX_XRAY_CURRENT || [[self preferences] maxCurrent] <= MIN_XRAY_CURRENT) {
		[max_current_popup_button selectItemAtIndex:0];
	} else {
		int current_index = ([max_current_popup_button numberOfItems] - round([[self preferences] maxCurrent]/0.0001)) - 1;
		[max_current_popup_button selectItemAtIndex:current_index];
	}	
	[self maxCurrentChanged:self];
	
//	[max_voltage_popup_button removeAllItems];
//	for(int i=50; i>0; i-=5) {
//		NSString *title = [NSString stringWithFormat:@"%d kV", i];
//		[max_voltage_popup_button addItemWithTitle:title];
//	}
//	
//		int default_max_voltage_index = floor([max_voltage_popup_button numberOfItems]-([max_voltage_popup_button numberOfItems]*(([preferences maxVoltage]-1)/MAX_XRAY_VOLTAGE)));
//		[max_voltage_popup_button selectItemAtIndex:default_max_voltage_index-1];
//	}	
//	[self maxVoltageChanged:self];
//
//	[max_current_popup_button removeAllItems];
//	for(float f=1; f>0; f-=0.1) {
//		NSString *title = [NSString stringWithFormat:@"%.1f mA", f];
//		[max_current_popup_button addItemWithTitle:title];
//	}
//	
//	if ([preferences maxCurrent] >= MAX_XRAY_CURRENT || [preferences maxCurrent] <= MIN_XRAY_CURRENT) {
//		[max_current_popup_button selectItemAtIndex:0];
//	} else {
//		int default_max_current_index = floor([max_current_popup_button numberOfItems]-([max_current_popup_button numberOfItems]*([preferences maxCurrent]/MAX_XRAY_CURRENT)));
//		[max_current_popup_button selectItemAtIndex:default_max_current_index-1];
//	}	
//	[self maxCurrentChanged:self];
}

- (IBAction)browseForSaveLocationDir:(id)sender {
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setAllowsMultipleSelection:NO];
	
    int bp = [op runModal];
    if(bp == NSModalResponseOK) {
        NSArray * fn = [op filenames];
        NSEnumerator * fileEnum = [fn objectEnumerator];
        NSString * filename;
        while(filename = [fileEnum nextObject]) {
			[preferences setSaveLocation:filename];
        }
    }	
}

- (IBAction)maxCurrentChanged:(id)sender {
	float max_current = (([max_current_popup_button numberOfItems]-[max_current_popup_button indexOfSelectedItem])-1)*0.0001;	
	[preferences setMaxCurrent:max_current];
	
}

- (IBAction)maxVoltageChanged:(id)sender {
	float max_voltage = (([max_voltage_popup_button numberOfItems]-[max_voltage_popup_button indexOfSelectedItem])-1)*10000;	
	[preferences setMaxVoltage:max_voltage];	
}

- (XrayPreferences *)preferences {return preferences;}
- (void)setPreferences:(XrayPreferences *)new_preferences {
	preferences = new_preferences;
	
	// one off because of detector lag is special
	[self setDetectorLag:[preferences detectorLag]*1000];
}

//@synthesize preferences=preferences;

- (NSTimeInterval)detectorLag {
	return [preferences detectorLag]*1000;
}

- (void)setDetectorLag:(NSTimeInterval)new_detector_lag {
	[preferences setDetectorLag:new_detector_lag/1000];
}


@end
