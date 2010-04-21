//
//  XrayImageViewController.h
//  XRIPT
//
//  Created by bkennedy on 3/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayImageView.h"
#import "XrayConstants.h"
#import "XrayPreferences.h"
#import "XrayObjects.h"
#import "XrayBundle.h"

@interface XrayImageWindowController : NSWindowController {
	IBOutlet XrayImageView *image_view;

	unsigned short max_lut;
	unsigned short min_lut;
	
	int calibrate;
	int pixel_correct;
	
	BOOL enable_controls;
	BOOL enable_image_update;
	
	NSData *raw_image_data;
	NSRect current_subregion;
	NSData *cached_image;
	NSBitmapImageRep *full_sized_image;
	NSString *title;
	NSString *serial_number;
	Detector detector;
	
	XrayPreferences *preferences;
	XrayObjects *xray_objects;
	XrayBundle *current_bundle;
}

- (id)initWithWindowNibName:(NSString *)nib_name 
				   andTitle:(NSString *)new_title
			 andPreferences:(XrayPreferences *)new_preferences 
			 andXrayObjects:(XrayObjects *)new_xray_objects 
				andDetector:(Detector)new_detector 
			andSerialNumber:(NSString *)new_serial_number;

// accessor methods
- (unsigned short)maxLUT;
- (void)setMaxLUT:(unsigned short)new_max_lut;
- (unsigned short)minLUT;
- (void)setMinLUT:(unsigned short)new_min_lut;
- (int)calibrate;
- (void)setCalibrate:(int)new_calibrate;
- (int)pixelCorrect;
- (void)setPixelCorrect:(int)new_pixel_correct;
- (BOOL)enableControls;
- (void)setEnableControls:(BOOL)new_enable_controls;
- (NSData *)image;
- (void)setImage:(NSData *)new_image;
- (NSString *)title;
- (void)setTitle:(NSString *)new_title;
- (NSString *)serialNumber;
- (void)setSerialNumber:(NSString *)new_serial_number;
- (Detector)detector;
- (void)setDetector:(Detector)new_detector;
- (XrayPreferences *)preferences;
- (void)setPreferences:(XrayPreferences *)new_preferences;
- (XrayObjects *)xrayObjects;
- (void)setXrayObjects:(XrayObjects *)new_xray_objects;
- (XrayBundle *)currentBundle;
- (void)setCurrentBundle:(XrayBundle *)new_current_bundle;
- (NSData *)imageData;
- (void)setImageData:(NSData *)new_image_data;

//@property (readwrite) unsigned short maxLUT, minLUT;
//@property (readwrite) int calibrate, pixelCorrect;
//@property (readwrite) BOOL enableControls;
//@property (readwrite, copy) NSData *imageData;
//@property (readonly) NSImage *image;
//@property (readwrite, copy) NSString *title, *serialNumber;
//@property (readwrite) Detector detector;
//@property (readwrite, assign) id delegate;
//@property (readwrite, assign) XrayPreferences *preferences;

- (IBAction)imageAdjusted:(id)sender;
- (IBAction)imageReset:(id)sender;

@end

// Delegate Methods
@interface XrayImageWindowController (DelegateMethods)
- (BOOL)selectObjectAtPoint:(NSPoint)point;
- (void)pointSelected:(NSPoint)point;
- (void)pointMovedByX:(float)x andY:(float)y;
- (void)pointsMovedByX:(float)x andY:(float)y;
- (void)endMovePoints;
- (void)regionSelected:(NSRect)region;
- (NSArray *)pathsAndColorsWithBounds:(NSRect)bounds;
@end
