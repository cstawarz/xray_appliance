//
//  XrayImageWindowController.m
//  XRIPT
//
//  Created by bkennedy on 3/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayImageWindowController.h"
#import "CocoaShadoCam/RawImageConverter.h"
#import "NSImage-ProportionalImage.h"


@interface XrayImageWindowController(PrivateMethods)
- (NSBitmapImageRep *)convertRawToImage:(NSData *)data
				   withMaxLUT:(unsigned short)max_LUT
				   withMinLUT:(unsigned short)min_LUT
			  usingCorrection:(BOOL)should_correct_image
		  andUsingCalibration:(BOOL)should_calibrate_image;
- (void)refreshImage:(id)arg;
- (void)saveDefaults;
- (void)loadDefaults;
- (void)resetToFulSizedImage;
- (NSBitmapImageRep *)fullSizedImage;
- (void)setFullSizedImage:(NSBitmapImageRep *)new_full_sized_image;
- (void)updateImageView:(NSTimer *)the_timer;
@end

@implementation XrayImageWindowController


- (id)initWithWindowNibName:(NSString *)nib_name 
				   andTitle:(NSString *)new_title
			 andPreferences:(XrayPreferences *)new_preferences 
			 andXrayObjects:(XrayObjects *)new_xray_objects 
				andDetector:(Detector)new_detector 
			andSerialNumber:(NSString *)new_serial_number {
	self = [super initWithWindowNibName:nib_name];
	if(self != nil) {
		title = [new_title copy];
		preferences = new_preferences;
		xray_objects = new_xray_objects;
		detector = new_detector;
		serial_number = [new_serial_number copy];
	}
	return self;
}


- (void)awakeFromNib {
	[self setWindowFrameAutosaveName:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ windowFrameAutosaveName", title]];
	
	cached_image = nil;
	full_sized_image = nil;
	[self setEnableControls:YES];
	[self loadDefaults];
	
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateImageView:) userInfo:nil repeats:YES];
}
 

- (IBAction)imageAdjusted:(id)sender {
	[self setEnableControls:NO];

	[NSThread detachNewThreadSelector:@selector(refreshImage:) 
							 toTarget:self 
						   withObject:nil];	
	
	[self saveDefaults];
}

- (IBAction)imageReset:(id)sender {
	[self resetToFulSizedImage];
}

// accessor methods
- (unsigned short)maxLUT {return max_lut;}
- (void)setMaxLUT:(unsigned short)new_max_lut {max_lut=new_max_lut;}

- (unsigned short)minLUT {return min_lut;}
- (void)setMinLUT:(unsigned short)new_min_lut {min_lut = new_min_lut;}

- (int)calibrate {return calibrate;}

- (void)setCalibrate:(int)new_calibrate {calibrate=new_calibrate;}
- (int)pixelCorrect {return pixel_correct;}
- (void)setPixelCorrect:(int)new_pixel_correct {pixel_correct = new_pixel_correct;}

- (BOOL)enableControls {return enable_controls;}
- (void)setEnableControls:(BOOL)new_enable_controls {enable_controls = new_enable_controls;}

- (NSData *)image {return cached_image;}
- (void)setImage:(NSData *)new_image {
	cached_image = [new_image copy];
}

- (NSString *)title {return title;}
- (void)setTitle:(NSString *)new_title {
	title = [new_title copy];
}

- (NSString *)serialNumber {return serial_number;}
- (void)setSerialNumber:(NSString *)new_serial_number {
	serial_number = [new_serial_number copy];
}

- (XrayPreferences *)preferences {return preferences;}
- (void)setPreferences:(XrayPreferences *)new_preferences {
	preferences = new_preferences;
}

- (XrayObjects *)xrayObjects {return xray_objects;}
- (void)setXrayObjects:(XrayObjects *)new_xray_objects {
	xray_objects = new_xray_objects;
}

- (XrayBundle *)currentBundle { return current_bundle;}
- (void)setCurrentBundle:(XrayBundle *)new_current_bundle {
	current_bundle = new_current_bundle;
}

- (Detector)detector {return detector;}
- (void)setDetector:(Detector)new_detector {detector=new_detector;}

- (NSData *)imageData {
	return raw_image_data;
}

- (void)setImageData:(NSData *)new_raw_data {
	raw_image_data = new_raw_data;

	NSBitmapImageRep *new_image = [self convertRawToImage:[self imageData] 
											   withMaxLUT:[self maxLUT]
											   withMinLUT:[self minLUT]
                                          usingCorrection:([self pixelCorrect] == NSControlStateValueOn)
                                      andUsingCalibration:([self calibrate] == NSControlStateValueOn)];
	
	@synchronized(cached_image) {
		[self setImage:[new_image TIFFRepresentation]];
	}
	[self setFullSizedImage:new_image];
	
	current_subregion = NSMakeRect(0,
								   0,
								   [[self fullSizedImage] size].width,
								   [[self fullSizedImage] size].height);		
}


//@synthesize preferences=preferences, maxLUT=max_lut, minLUT=min_lut, calibrate=calibrate, pixelCorrect=pixel_correct, title=title, serialNumber=serial_number, enableControls = enable_controls, detector=detector;


///////////////////////////////////////////////////////////////////////////////
// delegate methods
///////////////////////////////////////////////////////////////////////////////
- (BOOL)selectObjectAtPoint:(NSPoint)point {
	NSPoint new_point = NSMakePoint(current_subregion.origin.x + (current_subregion.size.width*point.x), 
									(current_subregion.origin.y + (current_subregion.size.height*point.y)));

	// get the current list of xray objects
	NSArray *xray_elements = [[[self xrayObjects] currentSet] objectForKey:XRAY_OBJECTS];
	NSMutableIndexSet *new_selected_objects_index = [NSMutableIndexSet indexSet];
	
	int window_size = [[self preferences] centerFinderWindowSize]/2;
	
	for (int i=0; i<[xray_elements count]; ++i) {
		XrayObject *xro = [xray_elements objectAtIndex:i];
		NSPoint existing_point = [[xro plotableObject] pointForDetector:[self detector]];
		if(fabs(new_point.x-existing_point.x) < window_size && fabs(new_point.y-existing_point.y) < window_size) {
			[new_selected_objects_index addIndex:i];
		}
	}
	
	if([new_selected_objects_index count] > 0) {
		[[self xrayObjects] setCurrentIndexes:new_selected_objects_index];
		return YES;
	}
	
	return NO;
}

- (void)pointSelected:(NSPoint)point {
	NSPoint new_point = NSMakePoint(current_subregion.origin.x + (current_subregion.size.width*point.x), 
									(current_subregion.origin.y + (current_subregion.size.height*point.y)));
	
	XrayObject *xro = [[self xrayObjects] currentObject];
	[[xro plotableObject] setPoint:new_point 
					   forDetector:[self detector]];
	
	// Maybe this isn't the best idea
	Detector other_detector;
	switch([self detector]) {
		case DETECTOR_1:
			other_detector = DETECTOR_2;
			break;
		case DETECTOR_2:
			other_detector = DETECTOR_1;
			break;
		default:
			[NSException raise:NSInternalInconsistencyException
						format:@"[XrayImageWindowController pointSelected:] current detector doesn't make any sense"];
			break;
	}
	
	NSPoint point_on_other_detector = [[xro plotableObject] pointForDetector:other_detector];
	if(point_on_other_detector.x < 0 && point_on_other_detector.y < 0) {
		
		NSSize image_size = [[self fullSizedImage] size];
		
		int current_index = [[[self xrayObjects] currentIndexes] firstIndex];
		int number_of_objects = [[[[self xrayObjects] currentSet] objectForKey:XRAY_OBJECTS] count];
		
		[[xro plotableObject] setPoint:NSMakePoint(image_size.height-(image_size.width/4+((image_size.width/2)/number_of_objects)*current_index), 
												   image_size.height/4+((image_size.height/2)/number_of_objects)*current_index)
						   forDetector:other_detector];
	}
	
	// end possible bad idea	
	
	[current_bundle writeXrayElements];
	[self resetToFulSizedImage];
}

- (void)pointMovedByX:(float)x_difference andY:(float)y_difference {
	float actual_x_difference = current_subregion.size.width*x_difference;
	float actual_y_difference = current_subregion.size.height*y_difference;

	NSImage *current_image = [[NSImage alloc] initWithData:[self image]]; 
	NSSize image_size = [current_image size];
	

	XrayObject *xro = [[self xrayObjects] currentObject];
	NSPoint existing_point = [[xro plotableObject] pointForDetector:[self detector]];
	if(existing_point.x > 0 && existing_point.y > 0) {
		NSPoint new_point = NSMakePoint(existing_point.x+actual_x_difference, 
										existing_point.y+actual_y_difference);
		
			// if it goes off the screen, reset it to -1,-1
		if(new_point.x < 0 || 
		   new_point.y < 0 || 
		   new_point.x > image_size.width || 
		   new_point.y > image_size.height) {
			new_point = NSMakePoint(-1, -1);
		}
		
		[[xro plotableObject] setPoint:new_point forDetector:[self detector]];
	}
}
	
- (void)pointsMovedByX:(float)x_difference andY:(float)y_difference {
	float actual_x_difference = current_subregion.size.width*x_difference;
	float actual_y_difference = current_subregion.size.height*y_difference;
	NSImage *current_image = [[NSImage alloc] initWithData:[self image]]; 
	NSSize image_size = [current_image size];
	
	// get the current list of xray objects
	NSEnumerator *enumerator = [[[[self xrayObjects] currentSet] objectForKey:XRAY_OBJECTS] objectEnumerator];
	XrayObject *xro;
	
	while(xro = [enumerator nextObject]) {
		NSPoint existing_point = [[xro plotableObject] pointForDetector:[self detector]];
		if(existing_point.x > 0 && existing_point.y > 0) {
			NSPoint new_point = NSMakePoint(existing_point.x+actual_x_difference, 
											existing_point.y+actual_y_difference);
			
			// if it goes off the screen, reset it to -1,-1
			if(new_point.x < 0 || 
			   new_point.y < 0 || 
			   new_point.x > image_size.width || 
			   new_point.y > image_size.height) {
				new_point = NSMakePoint(-1, -1);
			}
			
			[[xro plotableObject] setPoint:new_point forDetector:[self detector]];
		}
	}	
}

- (void)endMovePoints {
	[current_bundle writeXrayElements];	
}

- (void)regionSelected:(NSRect)selected_region {	
	NSRect new_subregion = NSMakeRect(floor(current_subregion.origin.x+current_subregion.size.width*selected_region.origin.x),
									  floor(current_subregion.origin.y+current_subregion.size.height*selected_region.origin.y),
									  ceil(current_subregion.size.width*selected_region.size.width),
									  ceil(current_subregion.size.height*selected_region.size.height));
	
	
	NSImage *working_image = [[NSImage alloc] initWithData:[[self fullSizedImage] TIFFRepresentation]];
		
	[working_image lockFocus];
	NSBitmapImageRep *sub_image_rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:new_subregion];
	[working_image unlockFocus];
	
	NSImage *sub_image = [[NSImage alloc] initWithData:[sub_image_rep TIFFRepresentation]];
	
	// scale the visible image proportionatly so it takes up the whole window
	float actual_height_width_ratio = [sub_image size].height/[sub_image size].width;
	
	NSSize visible_size = [[image_view cell] drawingRectForBounds:[image_view bounds]].size;
	float visible_height_width_ratio = visible_size.height/visible_size.width;
	
	NSSize actual_image_size;
	if(actual_height_width_ratio > visible_height_width_ratio) {
		// the image is limited by height
		actual_image_size.height = ceil(visible_size.height);
		actual_image_size.width = ceil(actual_image_size.height/actual_height_width_ratio);		
		
	} else {
		// the image is limited by width
		actual_image_size.width = ceil(visible_size.width);
		actual_image_size.height = ceil(actual_image_size.width*actual_height_width_ratio);
	}
	
	@synchronized(cached_image) {
		[self setImage:[[sub_image imageByScalingProportionallyToSize:actual_image_size] TIFFRepresentation]];
	}
	
	current_subregion = new_subregion;
}

- (NSArray *)pathsAndColorsWithBounds:(NSRect)bounds {
	NSMutableArray *paths_and_colors = [NSMutableArray array];
	
	NSArray *keys = [NSArray arrayWithObjects:XRAY_OBJECT_COLOR, XRAY_OBJECT_PATH, nil];
	
	XrayObjects *xrayObjects = [self xrayObjects];
	NSEnumerator *xray_object_enumerator = [[[xrayObjects currentSet] objectForKey:XRAY_OBJECTS] objectEnumerator];
	XrayObject *xro = nil;
	
	while(xro = [xray_object_enumerator nextObject]) {
		NSBezierPath *path = [[xro plotableObject] pathOnDetector:[self detector]
													   withBounds:bounds
													  imageRegion:current_subregion
														 viewSize:[image_view frame].size
										andCenterFinderWindowSize:NSMakeSize([preferences centerFinderWindowSize],
																			 [preferences centerFinderWindowSize])];
		
		NSArray *values = [NSArray arrayWithObjects:[[xro plotableObject] color], path, nil];
		[paths_and_colors addObject:[NSDictionary dictionaryWithObjects:values forKeys:keys]];
	}
	
	return paths_and_colors;
}

///////////////////////////////////////////////////
// Private Methods
///////////////////////////////////////////////////
- (NSBitmapImageRep *)convertRawToImage:(NSData *)raw_data
				   withMaxLUT:(unsigned short)max_LUT
				   withMinLUT:(unsigned short)min_LUT
			  usingCorrection:(BOOL)should_correct_image
		  andUsingCalibration:(BOOL)should_calibrate_image {
	
	return [RawImageConverter convertRawToImage:raw_data
									 withMaxLUT:max_LUT
									 withMinLUT:min_LUT
								andSerialNumber:[self serialNumber]
								usingCorrection:should_correct_image
							andUsingCalibration:should_calibrate_image];
}

- (NSBitmapImageRep *)fullSizedImage {return full_sized_image;}
- (void)setFullSizedImage:(NSBitmapImageRep *)new_full_sized_image {
	full_sized_image = [new_full_sized_image copy];
}

- (void)resetToFulSizedImage {
	@synchronized(cached_image) {
		[self setImage:[[self fullSizedImage] TIFFRepresentation]];
	}
	
	current_subregion = NSMakeRect(0,
								   0,
								   [[self fullSizedImage] size].width,
								   [[self fullSizedImage] size].height);			
}

- (void)loadDefaults {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[self setMaxLUT:[ud integerForKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - max_lut", title]]];
	[self setMinLUT:[ud integerForKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - min_lut", title]]];
	[self setPixelCorrect:[ud integerForKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - pixel_correction", title]]];	
	[self setCalibrate:[ud integerForKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - calibrate", title]]];
}

- (void)saveDefaults {	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	[ud setInteger:[self pixelCorrect] forKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - pixel_correction", title]];
	[ud setInteger:[self calibrate] forKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - calibrate", title]];
	[ud setInteger:[self maxLUT] forKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - max_lut", title]];
	[ud setInteger:[self minLUT] forKey:[NSString stringWithFormat:@"XRIPT - XrayImageWindowController - %@ - min_lut", title]];
	
	[ud synchronize];
}

- (void)refreshImage:(id)arg {
	@autoreleasepool {	
	
	// make this smarter so it doesn't reset to the bigger image
		NSBitmapImageRep *new_image = [self convertRawToImage:[self imageData] 
												   withMaxLUT:[self maxLUT]
												   withMinLUT:[self minLUT]
                                          usingCorrection:([self pixelCorrect] == NSControlStateValueOn)
                                      andUsingCalibration:([self calibrate] == NSControlStateValueOn)];
		
		@synchronized(cached_image) {
			[self setImage:[new_image TIFFRepresentation]];
		}
		
		[self setFullSizedImage:new_image];
		// shouldn't need to do this, but it recreates the larger image again, sothe subregion needs to be reset:
		
		
		current_subregion = NSMakeRect(0,
									   0,
									   [new_image size].width,
									   [new_image size].height);		
		
		[current_bundle setImage:[[self fullSizedImage] TIFFRepresentation] forDetector:[self detector]];
		[current_bundle performSelectorOnMainThread:@selector(writeImages:)
										 withObject:self
									  waitUntilDone:YES];
		
		[self setEnableControls:YES];
	}
}

- (void)updateImageView:(NSTimer *)the_timer {
	@synchronized(cached_image) {
		[image_view setNeedsDisplay:YES];
	}
}



@end
