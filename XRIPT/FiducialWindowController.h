//
//  FiducialWindowController.h
//  XRIPT
//
//  Created by bkennedy on 3/21/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayObjects.h"


@interface FiducialWindowController : NSWindowController {
	IBOutlet NSPopUpButton *nfs_titles_popup_button;
	
	id delegate;
	XrayObjects *xray_objects;
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andXrayObjects:(XrayObjects *)new_xray_objects;

- (XrayObjects *)xrayObjects;
- (void)setXrayObjects:(XrayObjects *)new_xray_objects;

- (id)delegate;
- (void)setDelegate:(id)new_delegate;

//@property (readwrite, assign) XrayObjects *xrayObjects;
//@property (readwrite, assign) id delegate;

	
//// something is binding to this and it's being a pain in the ass
//@property (readonly) NSString *name;
- (NSString *)name;

- (IBAction)selectedObjectChanged:(id)sender;
- (IBAction)selectedSetChanged:(id)sender;
- (IBAction)openAddWindow:(id)sender;
@end
