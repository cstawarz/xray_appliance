//
//  OperationsWindowController.h
//  XRIPT
//
//  Created by Ben Kennedy on 1/26/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FFORManager.h"
#import "XrayBundle.h"
#import "XrayPreferences.h"
#import "XrayObjects.h"
#import "CocoaMxArray.h"

@interface OperationsWindowController : NSWindowController {
	IBOutlet NSPopUpButton *possible_projections_popup_button;
	IBOutlet NSTextField *principle_crv_text_field;
	IBOutlet NSTextField *overlay_crv_text_field;
		
	NSArray *possible_projections;
	NSString *object_to_project;
	
	FFORManager *ffor_manager;
	NSIndexSet *current_possible_ffor_indexes;
	NSIndexSet *current_ffor_to_use_indexes;
	NSArray *ffors_to_use;
	
	NSString *principle_crv_path;
	NSString *overlay_crv_path;
	NSString *status_message;

	float overlay_opacity;
	
	XrayBundle *bundle;
	XrayObjects *xray_objects;
	XrayPreferences *preferences;
	
	BOOL reconstruction_ready;
	BOOL coregistration_ready;
	BOOL can_reconstruct;
	BOOL buttons_enabled;
	
	int overlay;
	
	NSLock *op_lock;
	NSColor *coregistration_text_color;
	NSColor *projection_text_color;
	
	/// curently using MATLAB mxArray to store this
	CocoaMxArray *current_principal_crv;
	CocoaMxArray *current_overlay_crv;
	
}

- (float)overlayOpacity;
- (void)setOverlayOpacity:(float)new_overlay_opacity;

- (int)overlay;
- (void)setOverlay:(int)new_overlay;

- (BOOL)reconstructionReady;
- (void)setReconstructionReady:(BOOL)new_reconstruction_ready;

- (BOOL)coregistrationReady;
- (void)setCoregistrationReady:(BOOL)new_coregsitration_ready;

- (BOOL)canReconstruct;
- (void)setCanReconstruct:(BOOL)new_can_reconstruct;

- (BOOL)buttonsEnabled;
- (void)setButtonsEnabled:(BOOL)new_buttons_enabled;

- (XrayBundle *)bundle;
- (void)setBundle:(XrayBundle *)new_bundle;

- (XrayObjects *)xrayObjects;
- (void)setXrayObjects:(XrayObjects *)new_xray_objects;

- (XrayPreferences *)preferences;
- (void)setPreferences:(XrayPreferences *)new_preferences;

- (NSString *)statusMessage;
- (void)setStatusMessage:(NSString *)new_status_message;

- (FFORManager *)fforManager;
- (void)setFforManager:(FFORManager *)new_ffor_manager;

- (NSArray *)fforsToUse;
- (void)setFforsToUse:(NSArray *)new_ffors_to_use;

- (NSArray *)possibleProjections;
- (void)setPossibleProjections:(NSArray *)new_possible_projections;

- (NSString *)principleCRVPath;
- (void)setPrincipleCRVPath:(NSString *)new_principle_crv_path;

- (NSString *)overlayCRVPath;
- (void)setOverlayCRVPath:(NSString *)new_overlay_crv_path;

- (NSString *)objectToProject;
- (void)setObjectToProject:(NSString *)new_object_to_project;

- (NSIndexSet *)currentPossibleIndexes;
- (void)setCurrentPossibleIndexes:(NSIndexSet *)new_current_possible_indexes;

- (NSIndexSet *)currentFFORsToUseIndexes;
- (void)setCurrentFFORsToUseIndexes:(NSIndexSet *)new_current_ffors_to_use_indexes;

- (NSColor *)projectionLabelColor;
- (void)setProjectionLabelColor:(NSColor *)new_color;

- (NSColor *)coregistrationLabelColor;
- (void)setCoregistrationLabelColor:(NSColor *)new_color;

//@property (readwrite, retain) XrayBundle *bundle;
//@property (readwrite, assign) XrayObjects *xrayObjects;
//@property (readwrite, assign) XrayPreferences *preferences;
//@property (readwrite, copy) NSString *principleCRVPath, *overlayCRVPath, *objectToProject;
//@property (readwrite, assign) id delegate;
//@property (readwrite, copy) NSString *statusMessage;
//@property (readwrite) float overlayOpacity;
//@property (readwrite) int overlay;
//@property (readwrite) BOOL reconstructionReady, coregistrationReady, canReconstruct, buttonsEnabled;
//@property (readwrite, retain) FFORManager *fforManager;
//@property (readwrite, copy) NSIndexSet *currentPossibleIndexes, *currentFFORsToUseIndexes;
//@property (readwrite, retain) NSArray *fforsToUse;
//@property (readwrite, retain) NSArray *possibleProjections;


- (IBAction)findCenters:(id)sender;
- (IBAction)reconstruct3D:(id)sender;
- (IBAction)coregisterToFrames:(id)sender;
- (IBAction)projectToCRV:(id)sender;

- (IBAction)addFrame:(id)sender;
- (IBAction)deleteFrame:(id)sender;
- (IBAction)browseForCRV:(id)sender;
- (IBAction)browseForOverlay:(id)sender;

- (IBAction)pointToProjectChanged:(id)sender;
- (IBAction)overlayCheckboxChanged:(id)sender;
- (IBAction)overlayOpacityChanged:(id)sender;

@end

