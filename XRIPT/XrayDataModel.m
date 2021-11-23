//
//  XrayDataModel.m
//  XRIPT
//
//  Created by bkennedy on 3/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayDataModel.h"


@implementation XrayDataModel

- (id)init {
	self = [super init];
	if(self) {
		preferences = [[XrayPreferences alloc] init];
		xray_objects = [[XrayObjects alloc] init];
		ffor_manager = [[FFORManager alloc] init];
	}
	return self;
}



- (XrayObjects *)xrayObjects {return xray_objects;}
- (XrayPreferences *)preferences {return preferences;}
- (FFORManager *)fforManager {return ffor_manager;}
- (BOOL)xrayNotPrimed {return not_primed;}
- (void)setXrayNotPrimed:(BOOL)new_xray_not_primed {not_primed = new_xray_not_primed;}
- (BOOL)xrayNotOperating {return not_operating;}
- (void)setXrayNotOperating:(BOOL)new_xray_not_operating {not_operating = new_xray_not_operating;}
- (NSString *)statusMessage {return status_message;}
- (void)setStatusMessage:(NSString *)new_status_message {
	status_message = [new_status_message copy];
}
- (XrayBundle *)currentBundle {return current_bundle;}
- (void)setCurrentBundle:(XrayBundle *)new_current_bundle {
	current_bundle = new_current_bundle;
}

//@synthesize preferences=preferences, xrayObjects=xray_objects, fforManager=ffor_manager;
//@synthesize xrayNotPrimed=not_primed, xrayNotOperating=not_operating;
//@synthesize statusMessage=status_message;
//@synthesize currentBundle=current_bundle;


@end
