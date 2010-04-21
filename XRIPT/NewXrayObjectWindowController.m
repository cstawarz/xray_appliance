//
//  NewXrayObjectWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/21/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "NewXrayObjectWindowController.h"
#import "Electrode.h"
#import "Fiducial.h"


@implementation NewXrayObjectWindowController

- (id)initWithWindowNibName:(NSString *)nib_name
			 andXrayObjects:(XrayObjects *)new_xray_objects {
	self = [super initWithWindowNibName:nib_name];
	if(self != nil) {
		xray_objects = [new_xray_objects retain];
	}
	return self;
}

- (void) dealloc {
	[xray_objects release];
	[name release];
	[super dealloc];
}


- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:@"XRIPT - NewXrayObjectWindowController"];	
	[self setName:@"electrode"];
}

- (IBAction)addNewXrayObject:(id)sender {
	XrayObject *xro=nil;
	
	if([[type_button title] isEqualToString:@"Electrode"]) {
		xro = [Electrode electrodeWithName:[self name]];
	} else if([[type_button title] isEqualToString:@"Fiducial"]) {
		xro = [Fiducial fiducialWithName:[self name] andVisibility:@"x"];
	} else {
		[NSException raise:NSInternalInconsistencyException
					format:@"Trying to create an illegal xray object"];
	}
	
	[[xro plotableObject] setColor:[color_colorwell color]];
	
	[[self xrayObjects] addXrayObject:xro];
}

//@synthesize xrayObjects=xray_objects, name=name;
- (XrayObjects *)xrayObjects {return xray_objects;}
- (void)setXrayObjects:(XrayObjects *)new_xray_objects {
	[xray_objects release];
	xray_objects = [new_xray_objects retain];
}

- (NSString *)name {return name;}
- (void)setName:(NSString *)new_name {
	[name release];
	name = [new_name copy];
}


@end
