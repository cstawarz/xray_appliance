//
//  MainWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "MainWindowController.h"
#import "ApplicationController.h"

@implementation MainWindowController
- initWithPath:(NSString *)new_path {
	return [super initWithWindowNibName:@"MainWindow"];
}

- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:@"XRIPT - MainWindow"];	
}

- (void)setDelegate:(id)new_delegate {
	if (![new_delegate respondsToSelector:@selector(takeXray:)] ||
		![new_delegate respondsToSelector:@selector(primeXray:)]) {
		[NSException raise:NSInternalInconsistencyException 
					format:@"Delegate doesn't respond to required methods for MainWindowController"];			
	}
	
	delegate = new_delegate;
}

- (IBAction)primeXray:(id)sender {
	[NSThread detachNewThreadSelector:@selector(primeXray:) toTarget:delegate withObject:self];
}

- (IBAction)takeXray:(id)sender {
	[NSThread detachNewThreadSelector:@selector(takeXray:) toTarget:delegate withObject:self];
}

- (float)source1Voltage_kV {return source_1_voltage_kV;}
- (void)setSource1Voltage_kV:(float)new_voltage_kV {source_1_voltage_kV=new_voltage_kV;}
- (float)source1Current_mA {return source_1_current_mA;}
- (void)setSource1Current_mA:(float)new_current_mA {source_1_current_mA=new_current_mA;}

- (float)source2Voltage_kV {return source_2_voltage_kV;}
- (void)setSource2Voltage_kV:(float)new_voltage_kV {source_2_voltage_kV=new_voltage_kV;}
- (float)source2Current_mA {return source_2_current_mA;}
- (void)setSource2Current_mA:(float)new_current_mA {source_2_current_mA=new_current_mA;}

- (XrayDataModel *)model {return model;}
- (void)setModel:(XrayDataModel *)new_model {
    model = new_model;
}


//@synthesize source1Voltage=source_1_voltage_kV, source1Current=source_1_current_mA;
//@synthesize source2Voltage=source_2_voltage_kV, source2Current=source_2_current_mA;
//@synthesize model=model;

- (void)windowWillClose:(NSNotification *)a_notification {
	[NSApp terminate:self];
}

@end
