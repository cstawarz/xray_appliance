//
//  MainWindowController.h
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayDataModel.h"

@interface MainWindowController : NSWindowController {
	id delegate;
	
	float source_1_voltage_kV;
	float source_1_current_mA;
	float source_2_voltage_kV;
	float source_2_current_mA;
	
	XrayDataModel *model;

}

- (float)source1Voltage_kV;
- (void)setSource1Voltage_kV:(float)new_voltage_kV;
- (float)source1Current_mA;
- (void)setSource1Current_mA:(float)new_current_mA;

- (float)source2Voltage_kV;
- (void)setSource2Voltage_kV:(float)new_voltage_kV;
- (float)source2Current_mA;
- (void)setSource2Current_mA:(float)new_current_mA;

- (XrayDataModel *)model;
- (void)setModel:(XrayDataModel *)new_model;


//@property(readwrite) float  source1Voltage, source1Current, source2Voltage, source2Current;
//@property(readwrite, retain) XrayDataModel *model;

- (void)setDelegate:(id)new_delegate;
- (IBAction)primeXray:(id)sender;
- (IBAction)takeXray:(id)sender;

@end
