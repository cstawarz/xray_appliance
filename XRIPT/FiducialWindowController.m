//
//  FiducialWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/21/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "FiducialWindowController.h"
#import "ApplicationController.h"

#define XRIPT_NFS_TITLE @"XRIPT -- FiducialWindowController - Default NFS title"



@implementation FiducialWindowController
- initWithPath:(NSString *)new_path {
	return [super initWithWindowNibName:@"FiducialWindow"];
}

- (id)initWithWindowNibName:(NSString *)nib_name
			 andXrayObjects:(XrayObjects *)new_xray_objects {
	self = [super initWithWindowNibName:nib_name];
	if(self != nil) {
		xray_objects = [new_xray_objects retain];
	}
	return self;
}

- (void)dealloc {
	[xray_objects release];
	[super dealloc];
}

- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:@"XRIPT - FiducialWindowController"];	
	NSString *default_nfs_name = [[NSUserDefaults standardUserDefaults] stringForKey:XRIPT_NFS_TITLE];
	if(xray_objects && default_nfs_name) {
		[xray_objects setCurrentSetName:default_nfs_name];
		[nfs_titles_popup_button selectItemWithTitle:default_nfs_name];
	}
	
	[delegate setChanged:default_nfs_name];
}

- (id)delegate {return delegate;}
- (void)setDelegate:(id)new_delegate {
	if (![new_delegate respondsToSelector:@selector(openNewXrayObjectWindow:)] ||
		![new_delegate respondsToSelector:@selector(setChanged:)]) {
		[NSException raise:NSInternalInconsistencyException 
					format:@"Delegate doesn't respond to required methods for FiducialWindowController"];			
	}
	
	delegate = new_delegate;
}

- (IBAction)selectedSetChanged:(id)sender {
	[xray_objects setCurrentSetName:[sender title]];
	[[NSUserDefaults standardUserDefaults] setObject:[sender title] forKey:XRIPT_NFS_TITLE];
	[delegate setChanged:[sender title]];
}

- (IBAction)openAddWindow:(id)sender {
	[delegate openNewXrayObjectWindow:self];
}

- (IBAction)selectedObjectChanged:(id)sender {
	// this could be a bad idea
	Detector detectors[] = {DETECTOR_1, DETECTOR_2};
	
	for(int i=0; i < sizeof(detectors)/sizeof(*detectors); ++i) {
		XrayObject *xro = [[self xrayObjects] currentObject];
		
		NSPoint existing_point = [[xro plotableObject] pointForDetector:detectors[i]];
		if(existing_point.x < 0 && existing_point.y < 0) {
			[[xro plotableObject] setPoint:NSMakePoint(100,100) 
							   forDetector:detectors[i]];
		}
	}	
}

- (XrayObjects *)xrayObjects {return xray_objects;}
- (void)setXrayObjects:(XrayObjects *)new_xray_objects {
	[xray_objects release];
	xray_objects = [new_xray_objects retain];
}


//@synthesize xrayObjects=xray_objects, delegate=delegate;

// I don't know why this needs to be here
- (NSString  *)name {
	return nil;
}

@end
