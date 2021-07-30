//
//  OperationsWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "OperationsWindowController.h"
#import "OperationsWindowMATLABInterface.h"
#import "XrayObject.h"
#import "ApplicationController.h"
#import "CircleDetector.h"
#import "Reconstruct3D.h"
#import "CocoaFFOR.h"
#import "CoregisterToFrames.h"
#import "ProjectToCRV.h"

#define XRIPT_CRV_PATH @"XRIPT - OperationsWindowController crv_path"
#define XRIPT_OVERLAY_CRV_PATH @"XRIPT - OperationsWindowController overlay_path"
#define XRIPT_OVERLAY @"XRIPT - OperationsWindowController overlay"
#define XRIPT_OVERLAY_OPACITY @"XRIPT - OperationsWindowController overlay_opacity"
#define XRIPT_POINT_TO_PROJECT @"XRIPT - OperationsWindowController point_to_project"

@interface OperationsWindowController (PrivateMethods)
- (void)updateGUI:(NSTimer *)timer;
- (void)performReconstruction:(NSString *)bundle_path;
- (void)performFindCenters:(id)arg;
- (void)performCoregistration:(NSString *)bundle_path;
- (NSArray *)reconstructedXrayObjectNames;
@end

@implementation OperationsWindowController

- initWithPath:(NSString *)new_path {
	return [super initWithWindowNibName:@"PreferencesWindow"];
}

- (id)initWithWindowNibName:(NSString *)nib_name {
	self = [super initWithWindowNibName:nib_name]; 
	if(self != nil) {
//		frames_to_use = [[NSMutableArray alloc] init];
		op_lock = [[NSLock alloc] init];
		current_principal_crv = nil;
		current_overlay_crv = nil;
	}
	return self;
}

- (void) dealloc {
	[ffors_to_use release];
	
	[principle_crv_path release];
	[overlay_crv_path release];
	
	[object_to_project release];
	[possible_projections release];
	
	[status_message release];
	
	[current_principal_crv release];
	[current_overlay_crv release];
	[op_lock release];

	[bundle release];
	[super dealloc];
}

- (float)overlayOpacity {return overlay_opacity;}
- (void)setOverlayOpacity:(float)new_overlay_opacity {
	overlay_opacity = new_overlay_opacity;
}

- (int)overlay {return overlay;}
- (void)setOverlay:(int)new_overlay {
	overlay = new_overlay;
}

- (BOOL)reconstructionReady {return reconstruction_ready;}
- (void)setReconstructionReady:(BOOL)new_reconstruction_ready {
	reconstruction_ready = new_reconstruction_ready;
}

- (BOOL)coregistrationReady {return coregistration_ready;}
- (void)setCoregistrationReady:(BOOL)new_coregsitration_ready {
	coregistration_ready = new_coregsitration_ready;
}

- (BOOL)canReconstruct {return can_reconstruct;}
- (void)setCanReconstruct:(BOOL)new_can_reconstruct {
	can_reconstruct = new_can_reconstruct;
}

- (BOOL)buttonsEnabled {return buttons_enabled;}
- (void)setButtonsEnabled:(BOOL)new_buttons_enabled {
	buttons_enabled = new_buttons_enabled;
}

- (XrayBundle *)bundle {return bundle;}
- (void)setBundle:(XrayBundle *)new_bundle {
	[bundle release];
	bundle = [new_bundle retain];
}

- (XrayObjects *)xrayObjects {return xray_objects;}
- (void)setXrayObjects:(XrayObjects *)new_xray_objects {
	[xray_objects release];
	xray_objects = [new_xray_objects retain];
}

- (XrayPreferences *)preferences {return preferences;}
- (void)setPreferences:(XrayPreferences *)new_preferences {
	[preferences release];
	preferences = [new_preferences retain];
}

- (NSString *)statusMessage {return status_message;}
- (void)setStatusMessage:(NSString *)new_status_message {
	[status_message release];
	status_message = [new_status_message copy];
}

- (FFORManager *)fforManager {return ffor_manager;}
- (void)setFforManager:(FFORManager *)new_ffor_manager {
	[ffor_manager release];
	ffor_manager = [new_ffor_manager retain];
}

- (NSArray *)fforsToUse {return ffors_to_use;}
- (void)setFforsToUse:(NSArray *)new_ffors_to_use {
	[ffors_to_use release];
	ffors_to_use = [new_ffors_to_use retain];
}

- (NSArray *)possibleProjections {return possible_projections;}
- (void)setPossibleProjections:(NSArray *)new_possible_projections {
	[possible_projections release];
	possible_projections = [new_possible_projections retain];
}

- (NSString *)principleCRVPath {return principle_crv_path;}
- (void)setPrincipleCRVPath:(NSString *)new_principle_crv_path {
	[principle_crv_path release];
	principle_crv_path = [new_principle_crv_path copy];
	
	// storing the CRV
	[current_principal_crv autorelease];
	current_principal_crv = [[OperationsWindowMATLABInterface getCRV:principle_crv_path] retain];
}

- (NSString *)overlayCRVPath {return overlay_crv_path;}
- (void)setOverlayCRVPath:(NSString *)new_overlay_crv_path {
	[overlay_crv_path release];
	overlay_crv_path = [new_overlay_crv_path copy];		

	// storing the CRV
	[current_overlay_crv autorelease];
	current_overlay_crv = [[OperationsWindowMATLABInterface getCRV:overlay_crv_path] retain];
}

- (NSString *)objectToProject {return object_to_project;}
- (void)setObjectToProject:(NSString *)new_object_to_project {
	[object_to_project release];
	object_to_project = [new_object_to_project copy];		
	
}

- (NSIndexSet *)currentPossibleIndexes {return current_possible_ffor_indexes;}
- (void)setCurrentPossibleIndexes:(NSIndexSet *)new_current_possible_indexes {
	[current_possible_ffor_indexes release];
	current_possible_ffor_indexes = [new_current_possible_indexes copy];
}

- (NSIndexSet *)currentFFORsToUseIndexes {return current_ffor_to_use_indexes;}
- (void)setCurrentFFORsToUseIndexes:(NSIndexSet *)new_index_set {
	[current_ffor_to_use_indexes release];
	current_ffor_to_use_indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange([new_index_set firstIndex], 
																						 [[self fforsToUse] count]-[new_index_set firstIndex])];
}

- (NSColor *)projectionLabelColor { return projection_text_color; }
- (void)setProjectionLabelColor:(NSColor *)new_color {
	[projection_text_color release];
	projection_text_color = [new_color copy];
}

- (NSColor *)coregistrationLabelColor  { return coregistration_text_color; }
- (void)setCoregistrationLabelColor:(NSColor *)new_color {
	[coregistration_text_color release];
	coregistration_text_color = [new_color copy];	
}



//@synthesize bundle=bundle, overlayCRVPath=overlay_crv_path, principleCRVPath=principle_crv_path, delegate=delegate;
//@synthesize statusMessage=status_message, preferences=preferences, xrayObjects=xray_objects, overlayOpacity=overlay_opacity;
//@synthesize reconstructionReady=reconstruction_ready, coregistrationReady=coregistration_ready, overlay=overlay, canReconstruct=can_reconstruct;
//@synthesize buttonsEnabled=buttons_enabled;
//@synthesize fforManager=ffor_manager;
//@synthesize currentPossibleIndexes=current_possible_ffor_indexes, currentFFORsToUseIndexes=current_ffor_to_use_indexes;
//@synthesize fforsToUse=ffors_to_use;
//@synthesize objectToProject=object_to_project, possibleProjections=possible_projections;

- (void)awakeFromNib {
	[self setPrincipleCRVPath:[[NSUserDefaults standardUserDefaults] stringForKey:XRIPT_CRV_PATH]];
	[self setOverlayCRVPath:[[NSUserDefaults standardUserDefaults] stringForKey:XRIPT_OVERLAY_CRV_PATH]];
	
	[self setOverlay:[[NSUserDefaults standardUserDefaults] integerForKey:XRIPT_OVERLAY]];
	
	[self setWindowFrameAutosaveName:@"XRIPT - OperationsWindow"];	
	[[principle_crv_text_field cell] setLineBreakMode:NSLineBreakByTruncatingHead];
	[[overlay_crv_text_field cell] setLineBreakMode:NSLineBreakByTruncatingHead];
	
	[self setButtonsEnabled:YES];
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.2
									 target:self
								   selector:@selector(updateGUI:)
								   userInfo:nil
									repeats:YES];
	
}

- (IBAction)findCenters:(id)sender {
	[NSThread detachNewThreadSelector:@selector(performFindCenters:)
							 toTarget:self
						   withObject:nil];
}

- (IBAction)reconstruct3D:(id)sender {
	NSString *working_bundle = [NSString stringWithString:[[self bundle] path]];
	[NSThread detachNewThreadSelector:@selector(performReconstruction:)
							 toTarget:self
						   withObject:working_bundle];
}

- (IBAction)addFrame:(id)sender {
	CocoaFFOR *ffor_to_add = [[[self fforManager] possibleFFORs] objectAtIndex:[[self currentPossibleIndexes] firstIndex]];
	
	// do this nonsense to force the display to update
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[self fforsToUse]];
	[temp addObject:ffor_to_add];
	[self setFforsToUse:temp];

	[[self fforManager] setCurrentFFOR:ffor_to_add];
}

- (IBAction)deleteFrame:(id)sender {
	// do this nonsense to force the display to update
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[self fforsToUse]];
	[temp removeObjectsAtIndexes:[self currentFFORsToUseIndexes]];
	[self setFforsToUse:temp];
	
	// reset the FFOR manager
	if([[self fforsToUse] count] > 0) {
		[[self fforManager] setCurrentFFOR:[[self fforsToUse] lastObject]];
	} else {
		[[self fforManager] setCurrentXrayObjectNames:[NSArray array]];
	}
}

- (IBAction)projectToCRV:(id)sender {
	NSString *working_bundle = [NSString stringWithString:[[self bundle] path]];
	[NSThread detachNewThreadSelector:@selector(performProjection:)
							 toTarget:self
						   withObject:working_bundle];
}

- (IBAction)coregisterToFrames:(id)sender {
	NSString *working_bundle = [NSString stringWithString:[[self bundle] path]];
	[NSThread detachNewThreadSelector:@selector(performCoregistration:)
							 toTarget:self
						   withObject:working_bundle];
}

- (IBAction)browseForCRV:(id)sender {
    NSOpenPanel * op = [NSOpenPanel openPanel];
	[op setTitle:@"Select location of CRV to use"];
    [op setCanChooseDirectories:YES];
	[op setCanChooseFiles:YES];
    [op setAllowsMultipleSelection:NO];
	
    int bp = [op runModalForTypes:[NSArray arrayWithObjects:@"crv", nil]];
    if(bp == NSModalResponseOK) {
        NSArray * fn = [op filenames];
        NSEnumerator * fileEnum = [fn objectEnumerator];
        NSString * filename;
        while(filename = [fileEnum nextObject]) {
			[self setPrincipleCRVPath:filename];

			[[NSUserDefaults standardUserDefaults] setObject:[self principleCRVPath]
													  forKey:XRIPT_CRV_PATH];
			
			[[NSUserDefaults standardUserDefaults] synchronize];
        }
    }	
}

- (IBAction)browseForOverlay:(id)sender {
    NSOpenPanel * op = [NSOpenPanel openPanel];
	[op setTitle:@"Select location of CRV to use"];
    [op setCanChooseDirectories:YES];
	[op setCanChooseFiles:YES];
    [op setAllowsMultipleSelection:NO];
	
    int bp = [op runModalForTypes:[NSArray arrayWithObjects:@"crv", nil]];
    if(bp == NSModalResponseOK) {
        NSArray * fn = [op filenames];
        NSEnumerator * fileEnum = [fn objectEnumerator];
        NSString * filename;
        while(filename = [fileEnum nextObject]) {
			[self setOverlayCRVPath:filename];
			[[NSUserDefaults standardUserDefaults] setObject:[self overlayCRVPath]
													  forKey:XRIPT_OVERLAY_CRV_PATH];
			
			[[NSUserDefaults standardUserDefaults] synchronize];
        }
    }	
}

- (IBAction)pointToProjectChanged:(id)sender {
	[self setObjectToProject:[sender title]];
	[[NSUserDefaults standardUserDefaults] setObject:[sender title]
											  forKey:XRIPT_POINT_TO_PROJECT];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)overlayCheckboxChanged:(id)sender {
	[[NSUserDefaults standardUserDefaults] setInteger:[self overlay]
											   forKey:XRIPT_OVERLAY];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

- (IBAction)overlayOpacityChanged:(id)sender {
	[[NSUserDefaults standardUserDefaults] setFloat:[self overlayOpacity]
											 forKey:XRIPT_OVERLAY_OPACITY];
	[[NSUserDefaults standardUserDefaults] synchronize];		
}


- (void)updateGUI:(NSTimer *)TimerUPP {
	if([op_lock tryLock]) {
		if(![self buttonsEnabled]) {
			
		}
		
		[self setPossibleProjections:[OperationsWindowMATLABInterface reconstructedObjectNamesForBundle:[self bundle]]];
		
		if([self objectToProject] != nil) {
			if([possible_projections_popup_button itemWithTitle:[self objectToProject]] != nil) {
				[possible_projections_popup_button selectItemWithTitle:[self objectToProject]];
			//		NSLog(@"%@ is being selected\n", self.objectToProject);
				
			} else {
			//		NSLog(@"%@ doesn't exist\n", self.objectToProject);
			}
		}
		
		NSEnumerator *current_xray_objects_enumerators = [[[self xrayObjects] currentXrayObjects] objectEnumerator];
		XrayObject *xro = nil;
		int num_selected_points = 0;
		
		while(xro = [current_xray_objects_enumerators nextObject]) {
			NSPoint d1_point = [[xro plotableObject] pointForDetector:DETECTOR_1];
			NSPoint d2_point = [[xro plotableObject] pointForDetector:DETECTOR_2];
			
			if(d1_point.x > 0 &&
			   d1_point.y > 0 &&
			   d2_point.x > 0 &&
			   d2_point.y > 0) {
				num_selected_points++;
			}
		}
		
		[self setCanReconstruct:num_selected_points > 0];
		
		[self setReconstructionReady:[Reconstruct3D isReconstructionAvailable:[[self bundle] path]]];
		if([self reconstructionReady] && [self buttonsEnabled]) {
			[self setCoregistrationLabelColor:[NSColor controlTextColor]];
		} else {
			[self setCoregistrationLabelColor:[NSColor secondarySelectedControlColor]];			
		}
		
		[self setCoregistrationReady:[CoregisterToFrames isBundleCoregistered:[[self bundle] path]
																	 toFrames:[self fforsToUse]]];
		if([self coregistrationReady] && [self buttonsEnabled]) {
			[self setProjectionLabelColor:[NSColor controlTextColor]];
		} else {
			[self setProjectionLabelColor:[NSColor secondarySelectedControlColor]];			
		}
		
		
		if([[[self fforManager] possibleFFORs] count] == 0 && [[self fforsToUse] count] == 0) {
			[[self fforManager] setCurrentXrayObjectNames:[self reconstructedXrayObjectNames]];
		}
		
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		
		if([ud stringForKey:XRIPT_POINT_TO_PROJECT] != nil) {
			[possible_projections_popup_button selectItemWithTitle:[ud stringForKey:XRIPT_POINT_TO_PROJECT]];
			if([[[possible_projections_popup_button selectedItem] title] isEqualToString:[ud stringForKey:XRIPT_POINT_TO_PROJECT]]) {
				[self setObjectToProject:[ud stringForKey:XRIPT_POINT_TO_PROJECT]];
			}
		}
		
		[self setOverlayOpacity:[ud floatForKey:XRIPT_OVERLAY_OPACITY]];
		
		[op_lock unlock];
	}
}
	
- (void)performReconstruction:(NSString *)bundle_path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self setButtonsEnabled:NO];
	
	[self setStatusMessage:@"Performing 3D reconstruction"];

	[op_lock lock];
	BOOL success = [Reconstruct3D reconstructBundle:bundle_path];
	[op_lock unlock];
	
	if(!success) {
		[self setStatusMessage:@"Could not perform reconstruction"];
	} else {
		[self setStatusMessage:@"3D reconstruction complete"];
	}	
	
	[self setButtonsEnabled:YES];
	[pool release];
}

- (void)performFindCenters:(id)arg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setButtonsEnabled:NO];
	
	Detector detectors[] = {DETECTOR_1, DETECTOR_2};
	
	for(int i=0; i < sizeof(detectors)/sizeof(*detectors); ++i) {
		
		NSString *detector_number = nil;
		switch(detectors[i]) {
			case DETECTOR_1:
				detector_number = @"1";
				break;
			case DETECTOR_2:
				detector_number = @"2";
				break;
			default:
				[self setStatusMessage:@"Error performing center detection"];
				return;
				break;
		}
		
		NSEnumerator *current_xray_objects_enumerators = [[[[self xrayObjects] currentSet] objectForKey:XRAY_OBJECTS] objectEnumerator];
		XrayObject *xro = nil;
		
		while(xro = [current_xray_objects_enumerators nextObject]) {
			if([xro type] == FIDUCIAL && [xro isXrayVisible]) {
				[self setStatusMessage:[NSString stringWithFormat:@"Finding center of %@ on detector %@", 
					[xro name], 
					detector_number]];
				
				NSSize window_size = NSMakeSize([[self preferences] centerFinderWindowSize],
												[[self preferences] centerFinderWindowSize]);
				
				int max_window_size_dimension = (window_size.width > window_size.height) ? window_size.width : window_size.height;
				
				NSData *current_image = [[self bundle] imageForDetector:detectors[i]];
								
				NSPoint new_center = [CircleDetector circleCenterOnImage:current_image
														  usingSeedPoint:[[xro plotableObject] pointForDetector:detectors[i]]
														   andWindowSize:max_window_size_dimension];

				
				[[xro plotableObject] setPoint:new_center forDetector:detectors[i]];
			}
		}

		[self setStatusMessage:@"Center detection complete"]; 
	}
	
	[self setButtonsEnabled:YES];
	
	[pool release];
}

- (void)performCoregistration:(NSString *)bundle_path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self setButtonsEnabled:NO];
	[self setStatusMessage:@"Performing coregistration"];
	
	[op_lock lock];
	BOOL success = [CoregisterToFrames coregisterBundle:bundle_path
											usingFrames:[self fforsToUse]];
	[op_lock unlock];

	
	if(success) {
		[self setStatusMessage:@"Finished coregistration"];
	} else {
		[self setStatusMessage:@"Could not coregister"];
	}
	[self setButtonsEnabled:YES];
	[pool release];
}

- (void)performProjection:(NSString *)bundle_path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self setButtonsEnabled:NO];

	[self setStatusMessage:@"Performing projection"];
	
	[op_lock lock];
    if([self overlay] == NSControlStateValueOn) {
		[ProjectToCRV projectElement:[self objectToProject]
							 toFrame:[[[self fforsToUse] objectAtIndex:[[self fforsToUse] count]-1] name]
							toBundle:bundle_path
							usingCRV:current_principal_crv
						  andOverlay:current_overlay_crv
						  andOpacity:[self overlayOpacity]];		
	} else {
		[ProjectToCRV projectElement:[self objectToProject]
							 toFrame:[[[self fforsToUse] objectAtIndex:[[self fforsToUse] count]-1] name]
							toBundle:bundle_path
							usingCRV:current_principal_crv];		
	}
	[op_lock unlock];
	
	[self setStatusMessage:@"Projection complete"];

	[self setButtonsEnabled:YES];
	[pool release];
}

- (NSArray *)reconstructedXrayObjectNames {
	NSMutableArray *fiducial_names = [NSMutableArray array];
	
	NSEnumerator *reconstructed_object_enumerator = [[OperationsWindowMATLABInterface reconstructedObjectNamesForBundle:[self bundle]] objectEnumerator];
	NSString *object_name = nil;
	
	while(object_name = [reconstructed_object_enumerator nextObject]) {
		NSString *full_fiducial_name = [NSString stringWithFormat:@"%@.%@", [[[self xrayObjects] currentSet] objectForKey:XRAY_OBJECT_SET_NAME], object_name];
		[fiducial_names addObject:full_fiducial_name];
	}
	return fiducial_names;
}

@end
