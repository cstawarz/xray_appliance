//
//  NewXrayObjectWindowController.h
//  XRIPT
//
//  Created by bkennedy on 3/21/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayObjects.h"


@interface NewXrayObjectWindowController : NSWindowController {
    IBOutlet NSColorWell *color_colorwell;
	IBOutlet NSPopUpButton *type_button;
	XrayObjects *xray_objects;
	NSString *name;
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andXrayObjects:(XrayObjects *)new_xray_objects;

- (XrayObjects *)xrayObjects;
- (void)setXrayObjects:(XrayObjects *)new_xray_objects;
//@property (readwrite, assign) XrayObjects *xrayObjects;

- (NSString *)name;
- (void)setName:(NSString *)new_name;
//@property (readwrite, copy) NSString *name;

- (IBAction)addNewXrayObject:(id)sender;

@end
