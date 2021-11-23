//
//  ApplicationController.m
//  XRayBox
//
//  Created by Ben Kennedy on 2/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "ApplicationController.h"
#import "XrayConstants.h"
#import "CocoaFFOR.h"
#import "XrayBundle.h"

#import "Calibration.h"

@interface ApplicationController (PrivateMethods)
- (void)updateStateFired:(NSTimer *)the_timer;
- (NSData *)rawDataForDetector:(Detector)detector;
- (void)useNewBundle:(XrayBundle *)new_bundle;
@end

@implementation ApplicationController

- (id)init {
	self = [super init];
	if(self) {
		model = [[XrayDataModel alloc] init];
#if XRAY_DEVICES_ATTACHED
		daq = [[XRayNIDAQ alloc] initWithName:@"Dev1"];		

//		BOOL initializingNIDAQ = YES;
//		int initializingNIDAQcount = 0;
//		
//		while(initializingNIDAQ) {
//			@try {
//				daq = [[XRayNIDAQ alloc] initWithName:@"Dev1"];		
//			}
//			@catch (NSException * e) {
//				if(daq != nil) {
//					[daq release];
//				}
//						// try 5 times before quitting
//				if(++initializingNIDAQcount > 5) {
//					@throw e;
//				}
//			}
//			
//			if(daq != nil) {
//				initializingNIDAQ = NO;
//			}
//		}
		
		detector_1 = [[ShadoCam alloc] initWithPath:@"/Volumes/NO NAME"];
		detector_2 = [[ShadoCam alloc] initWithPath:@"/Volumes/NO NAME 1"];
		
		if([[detector_1 serialNumber] isEqualToString:@"0299"]) {
			ShadoCam *temp = detector_1;
			detector_1 = detector_2;
			detector_2=temp;
		}
		
		[detector_1 setTimingMode:TM_EXTERNAL_TRIGGER];
//		[detector_1 setTimingMode:TM_INTERNAL_TRIGGER];
//		int crap = [detector_1 timingMode];
//		[detector_1 setTimingMode:TM_EXTERNAL_TRIGGER];
//		[detector_1 setTimingMode:TM_INTERNAL_TRIGGER];
//		[detector_1 setTimingMode:TM_EXTERNAL_TRIGGER];
//		[detector_1 setTimingMode:TM_INTERNAL_TRIGGER];
		[detector_1 setOffsetCorrection:NO];
		[detector_1 setOffsetGain:0];
		[detector_1 setImageGain:0];
		[detector_1 setReset:YES];
		
		[detector_2 setTimingMode:TM_EXTERNAL_TRIGGER];
		[detector_2 setOffsetCorrection:NO];
		[detector_2 setOffsetGain:0];
		[detector_2 setImageGain:0];
		[detector_2 setReset:YES];
#endif
		
		[model setXrayNotPrimed:YES];
		[model setXrayNotOperating:YES];
		
		bundles = [[NSMutableArray alloc] init];
		
	}
	return self;
}

- (XrayDataModel *)model {
	return model;
}

//@synthesize model=model;

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	// create the xray objects to use
	
	NSFileManager *dfm = [NSFileManager defaultManager];
	NSDirectoryEnumerator *nfs_dir_enum = [dfm enumeratorAtPath:[[model preferences] nfsPath]];
	NSString *nfs_dir_item = nil;
	
	while(nfs_dir_item = [nfs_dir_enum nextObject]) {
		if([[nfs_dir_item pathExtension] isEqualToString:@"xml"]) {
			[[model xrayObjects] addNFS:[CocoaNFS nfsWithNamedFiducialSetPath:[[[model preferences] nfsPath] stringByAppendingPathComponent:nfs_dir_item]]];
		}
	}
	
	NSDirectoryEnumerator *ffor_dir_enum = [dfm enumeratorAtPath:[[model preferences] fforPath]];
	NSString *ffor_dir_item = nil;
	
	while(ffor_dir_item = [ffor_dir_enum nextObject]) {
		if([[ffor_dir_item pathExtension] isEqualToString:@"xml"]) {
			CocoaFFOR *ffor = [CocoaFFOR fforWithFiducialFrameOfReferencePath:[[[model preferences] fforPath] stringByAppendingPathComponent:ffor_dir_item] 
												 andNamedFiducialSetDirectory:[[model preferences] nfsPath]];
			[[model fforManager] addFFORToLibrary:ffor];
		}
	}
	
	
	calibration_window_controller = [[CalibrationWindowController alloc] initWithWindowNibName:@"CalibrationWindow" 
																				andPreferences:[model preferences]];
	[calibration_window_controller loadWindow];

	preferences_window_controller = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow" 
																				andPreferences:[model preferences]];
	[preferences_window_controller loadWindow];
	
	
	fiducial_window_controller = [[FiducialWindowController alloc] initWithWindowNibName:@"FiducialsWindow" 
																		  andXrayObjects:[model xrayObjects]];
	[fiducial_window_controller loadWindow];
	[fiducial_window_controller setDelegate:self];
	
	new_xray_object_window_controller = [[NewXrayObjectWindowController alloc] initWithWindowNibName:@"NewXrayObjectWindow" andXrayObjects:[model xrayObjects]];
	[new_xray_object_window_controller loadWindow];
	
	main_window_controller = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[main_window_controller showWindow:self];
	[main_window_controller setModel:model];
	[main_window_controller setDelegate:self];
	
	operations_window_controller = [[OperationsWindowController alloc] initWithWindowNibName:@"OperationsWindow"];
	[operations_window_controller loadWindow];
	[operations_window_controller close];
	[operations_window_controller setPreferences:[model preferences]];
	[operations_window_controller setFforManager:[model fforManager]];
	[operations_window_controller setXrayObjects:[model xrayObjects]];
	

#if XRAY_DEVICES_ATTACHED
	NSString *temp_d1_serial_number = [detector_1 serialNumber];
	NSString *temp_d2_serial_number = [detector_2 serialNumber];
#else
	NSString *temp_d1_serial_number = @"0187";
	NSString *temp_d2_serial_number = @"0299";
#endif
	
	detector_1_image_window_controller = [[XrayImageWindowController alloc] initWithWindowNibName:@"ImageViewer" 
																						 andTitle:@"D1"
																				   andPreferences:[model preferences]
																				   andXrayObjects:[model xrayObjects]
																					  andDetector:DETECTOR_1
																				  andSerialNumber:temp_d1_serial_number];
	[detector_1_image_window_controller loadWindow];
	[detector_1_image_window_controller close];
	
	detector_2_image_window_controller = [[XrayImageWindowController alloc] initWithWindowNibName:@"ImageViewer" 
																						 andTitle:@"D2"
																				   andPreferences:[model preferences]
																				   andXrayObjects:[model xrayObjects]
																					  andDetector:DETECTOR_2
																				  andSerialNumber:temp_d2_serial_number];
	
	
	[detector_2_image_window_controller loadWindow];
	[detector_2_image_window_controller close];
		
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(updateStateFired:)
								   userInfo:nil
									repeats:YES];
	
	
}

- (void)applicationWillTerminate:(NSNotification *)a_notification {
	[[model preferences] saveAsDefaults];
}


- (IBAction)openSettingsWindow:(id)sender {
	[preferences_window_controller showWindow:self];
}

- (IBAction)openCalibrationWindow:(id)sender {
	[calibration_window_controller showWindow:self];
}

- (IBAction)openBundle:(id)sender {
	NSOpenPanel * op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:YES];
	// it is important that you never allow multiple files to be selected!
	[op setAllowsMultipleSelection:NO];
    op.allowedFileTypes = @[@"xry"];
	
	
	
	int bp = [op runModal];
	if(bp == NSModalResponseOK) {
		NSArray * fn = [op filenames];
		NSEnumerator * fileEnum = [fn objectEnumerator];
		NSString * filename;
		while(filename = [fileEnum nextObject]) {
			XrayBundle *new_bundle = [XrayBundle bundleAtPath:filename];
			
			NSArray *xray_elements_in_bundle = [new_bundle xrayElements];
			[[model xrayObjects] useNewXrayObjects:xray_elements_in_bundle];
//			NSMutableDictionary *current_xray_object_set = [NSMutableDictionary dictionaryWithDictionary:[[model xrayObjects] currentSet]];
//			
//			[current_xray_object_set setObject:xray_elements_in_bundle forKey:XRAY_OBJECTS];
//			[[model xrayObjects] setCurrentSet:current_xray_object_set];
//			
//			NSEnumerator *bundle_elements_enumerator = [xray_elements_in_bundle objectEnumerator];
//			XrayObject *xro = nil;
//			
//			
//			while(xro = [bundle_elements_enumerator nextObject]) {
//				NSArray *working_xray_elements =  [[model xrayObjects] currentXrayObjects];
//				NSEnumerator *working_elements_enumerator = [working_xray_elements objectEnumerator];
//				XrayObject *xro2 = nil;
//
//				while(xro2 = [working_elements_enumerator nextObject]) {
//					if([[xro name] isEqualToString:[xro2 name]]) {
//						Detector detectors[] = {DETECTOR_1, DETECTOR_2};
//						for(int i=0; i < sizeof(detectors)/sizeof(*detectors); ++i) {
//							[[xro2 plotableObject] setPoint:[[xro plotableObject] pointForDetector:detectors[i]] 
//												forDetector:detectors[i]];
//						}
//					}
//				}
//			}
//			
			[new_bundle setXrayElements:[[model xrayObjects] currentXrayObjects]];
			
			[detector_1_image_window_controller setImageData:[new_bundle detector1RawData]];
			[detector_2_image_window_controller setImageData:[new_bundle detector2RawData]];

			[self useNewBundle:new_bundle];
			
			[[model preferences] setSubject:[new_bundle subject]];
			[[model preferences] setExperimenter:[new_bundle experimenter]];
			[[model preferences] setDetectorLag:[new_bundle detector1Lag]];
			[[model preferences] setSessionComment:[new_bundle sessionComment]];
			[[model preferences] setImageComment:[new_bundle imageComment]];
			
			
			[operations_window_controller performSelectorOnMainThread:@selector(showWindow:)
														   withObject:self
														waitUntilDone:NO];
			[fiducial_window_controller performSelectorOnMainThread:@selector(showWindow:)
														 withObject:self
													  waitUntilDone:NO];
			
			[detector_1_image_window_controller performSelectorOnMainThread:@selector(showWindow:)
																 withObject:self
															  waitUntilDone:NO];
			[detector_2_image_window_controller performSelectorOnMainThread:@selector(showWindow:)
																 withObject:self
															  waitUntilDone:NO];
			
			[model setStatusMessage:@"Bundle loaded"];
		}
	}	
}

//////////////////////////////////////////////////////////
// Delegate Methods
//////////////////////////////////////////////////////////
- (void)primeXray:(id)sender {
	@autoreleasepool {
		if([model xrayNotPrimed]) {
			[model setStatusMessage:@"Priming Xray"];
			
#if XRAY_DEVICES_ATTACHED
			[model setStatusMessage:@"Initializing Detector 1: setting integration time"];
			[detector_1 setIntegrationTime:[[model preferences] integrationTime]];                                                                                                              
			[model setStatusMessage:@"Initializing Detector 1: resetting"];                                                                                                                                                     
			[detector_1 setReset:NO];                                                                                                                                                              
			[detector_1 setReset:YES];                                                                                                                                                             
			
			[model setStatusMessage:@"Initializing Detector 2: setting integration time"];                                                                                                                                      
			[detector_2 setIntegrationTime:[[model preferences] integrationTime]];                                                                                                              
			[model setStatusMessage:@"Initializing Detector 2: resetting"];                                                                                                                                                     
			[detector_2 setReset:NO];                                                                                                                                                              
			[detector_2 setReset:YES];    		
			// ramp up sources' voltages
			//		const float MAX_XRAY_VOLTAGE_TO_REACH = [[model preferences] maxVoltage * MAX_XRAY_VOLTAGE;
			const float max_voltage_to_reach = [[model preferences] maxVoltage];
			
			
			float percentV = 0;
			float s1v = 0;
			float s2v = 0;
			
			const NSTimeInterval VOLTAGE_RAMP_SPEED = 0.12; // 120 ms/step
															// only wait for 5 seconds
			NSDate *fail_safe_time = [NSDate dateWithTimeIntervalSinceNow:5];
			
			[model setStatusMessage:@"Ramping high voltage sources"];			
			// ramp up voltage
			do {
				if(percentV < 1) {
					[daq setVoltageControl:[NSNumber numberWithFloat:(percentV+=0.05)]];
					[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:VOLTAGE_RAMP_SPEED]];
				}
				s1v = [[daq source1Voltage] floatValue];
				s2v = [[daq source2Voltage] floatValue];
			} while ((s1v < max_voltage_to_reach || 
					  s2v < max_voltage_to_reach) && [fail_safe_time timeIntervalSinceNow] > 0);
			
			
			const NSTimeInterval CURRENT_RAMP_SPEED = 0.07; // 70 ms/step
															// ramp up current
			for(float percentC = 0; percentC <= 1; percentC += 0.1) {
				[daq setCurrentControl:[NSNumber numberWithFloat:(percentC+0.1)]];
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:CURRENT_RAMP_SPEED]];
			}
#endif
			
			
			[model setXrayNotPrimed:NO];
			[model setStatusMessage:@"X-ray Primed"];
		}
	}
}

- (void)takeXray:(id)sender {
	@autoreleasepool {
		[model setStatusMessage:@"Taking X-ray"];
		[self primeXray:self];
		
		//	// close all of the auxillary windows
		[detector_1_image_window_controller performSelectorOnMainThread:@selector(close)
															 withObject:nil
														  waitUntilDone:YES];
		[detector_2_image_window_controller performSelectorOnMainThread:@selector(close)
															 withObject:nil
														  waitUntilDone:YES];
		[new_xray_object_window_controller performSelectorOnMainThread:@selector(close)
															withObject:nil
														 waitUntilDone:YES];
		[operations_window_controller performSelectorOnMainThread:@selector(close)
													   withObject:nil
													waitUntilDone:YES];
		[fiducial_window_controller performSelectorOnMainThread:@selector(close)
													 withObject:nil
												  waitUntilDone:YES];
		
		float source_1_voltage = 0;
		float source_2_voltage = 0;
		float source_1_current = 0;
		float source_2_current = 0;
		
		NSTimeInterval sources_on_time = 0;
		NSTimeInterval detectors_on_time = 0;
		NSTimeInterval detectors_lag_time = 0;
		
#if XRAY_DEVICES_ATTACHED
		//[self startAlarm];
		
		NSDate *sources_on = [NSDate date];
		[daq energizeSources:[NSNumber numberWithBool:YES]];
		
		// wait until the device reaches max current draw
		//	float MAX_XRAY_CURRENT = [[model preferences] maxCurrent;
		float max_xray_current_to_reach = [[model preferences] maxCurrent];
		[model setStatusMessage:@"Waiting for devices to reach max current"];
		
		float s1c = 0;
		float s2c = 0;
		
		NSDate *fail_safe_time = [NSDate dateWithTimeIntervalSinceNow:3];
		// if it's not going, only try for 3 seconds
		do {
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			//			usleep(100000);
			s1c = [[daq source1Current] floatValue];
			s2c = [[daq source2Current] floatValue];
		} while ((s1c < max_xray_current_to_reach || 
				  s2c < max_xray_current_to_reach) && [fail_safe_time timeIntervalSinceNow] > 0);
		
		// wait until cameras are ready
		[model setStatusMessage:@"Waiting for detectors"];
		if(![detector_1 pollUntilCameraReady:10] || 
		   ![detector_2 pollUntilCameraReady:10]) {
			NSLog(@"badness");
		}
		
		[model setStatusMessage:@"Taking X-ray"];
		
		NSDate *detectors_lag = [NSDate date];
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.140]];
		//		usleep(detector_lag);
		
		NSDate *detectors_on = [NSDate date];
		[daq activateDetectors:[NSNumber numberWithBool:YES]];
		detectors_lag_time = -1*[detectors_lag timeIntervalSinceNow];
		
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:[[model preferences] integrationTime]]];
		//		usleep([xbc integrationTime]);
		
		[model setStatusMessage:@"Powering down sources"];
		
		[daq activateDetectors:[NSNumber numberWithBool:NO]];
		detectors_on_time = -1*[detectors_on timeIntervalSinceNow];
		
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.140]];
		
		// get these values for storage
		source_1_voltage = [[daq source1Voltage] floatValue];
		source_2_voltage = [[daq source2Voltage] floatValue];
		source_1_current = [[daq source1Current] floatValue];
		source_2_current = [[daq source2Current] floatValue];
		
		[daq energizeSources:[NSNumber numberWithBool:NO]];
		sources_on_time = -1*[sources_on timeIntervalSinceNow];
		//	[xbc stopAlarm];
		
		// turn off sources
		[daq setCurrentControl:[NSNumber numberWithFloat:0]];
		[daq setVoltageControl:[NSNumber numberWithFloat:0]];
		
		[model setStatusMessage:@"Waiting for images"];
		if(![detector_1 pollUntilImageReady:10] || 
		   ![detector_2 pollUntilImageReady:10]) {
			NSLog(@"badness");
		}		
		
		
#endif
		[model setStatusMessage:@"Acquiring image 1"];
		NSData *detector_1_raw_data = [self rawDataForDetector:DETECTOR_1];
		[model setStatusMessage:@"Converting image 1"];
		[detector_1_image_window_controller setImageData:detector_1_raw_data];

		[model setStatusMessage:@"Acquiring image 2"];
		NSData *detector_2_raw_data = [self rawDataForDetector:DETECTOR_2];
		[model setStatusMessage:@"Converting image 2"];
		[detector_2_image_window_controller setImageData:detector_2_raw_data];
		
		[model setStatusMessage:@"Creating bundle"];
		
		XrayBundle *new_bundle = [XrayBundle bundleWithSubject:[[model preferences] subject] 
											   andExperimenter:[[model preferences] experimenter]
#if XRAY_DEVICES_ATTACHED
									  andDetector1SerialNumber:[detector_1 serialNumber]
									  andDetector2SerialNumber:[detector_2 serialNumber]
#else
									  andDetector1SerialNumber:@"0187"
									  andDetector2SerialNumber:@"0299"
#endif
									  andDetector1ExposureTime:detectors_on_time
									  andDetector2ExposureTime:detectors_on_time
											 andSource1Voltage:source_1_voltage
											 andSource2Voltage:source_2_voltage
											 andSource1Current:source_1_current
											 andSource2Current:source_2_current
											   andDetector1Lag:detectors_lag_time
											   andDetector2Lag:detectors_lag_time
											andSource1Duration:sources_on_time
											andSource2Duration:sources_on_time
											   andImageComment:[[model preferences] imageComment]
											 andSessionComment:[[model preferences] sessionComment]
														 andD1:[detector_1_image_window_controller image]
														 andD2:[detector_2_image_window_controller image]
													  andD1Raw:detector_1_raw_data
													  andD2Raw:detector_2_raw_data
												andCalibration:[[model preferences] calibration]
											   andXrayElements:[[[model xrayObjects] currentSet] objectForKey:XRAY_OBJECTS]];
		
		[self useNewBundle:new_bundle];
		[bundles addObject:new_bundle];
		
		[new_bundle writeBundleTo:[[model preferences] saveLocation]];
		
		if([new_bundle path] == nil) {
			[model setStatusMessage:@"Did not successfully write bundle"];
		} else {
			[operations_window_controller performSelectorOnMainThread:@selector(showWindow:)
														   withObject:self
														waitUntilDone:NO];
			[fiducial_window_controller performSelectorOnMainThread:@selector(showWindow:)
														 withObject:self
													  waitUntilDone:NO];
			[model setStatusMessage:@"X-ray completed"];
		}
		
		[detector_1_image_window_controller performSelectorOnMainThread:@selector(showWindow:)
															 withObject:self
														  waitUntilDone:NO];
		[detector_2_image_window_controller performSelectorOnMainThread:@selector(showWindow:)
															 withObject:self
														  waitUntilDone:NO];
		
		[model setXrayNotPrimed:YES];
		[model setXrayNotOperating:YES];
	
	}
}

- (void)openNewXrayObjectWindow:(id)sender {
	[new_xray_object_window_controller showWindow:sender];	
}

- (void)setChanged:(NSString *)new_set_name {
	[[model currentBundle] setXrayElements:[[[model xrayObjects] currentSet] objectForKey:XRAY_OBJECTS]];
}

//////////////////////////////////////////////////////////
// Private Methods
/////////////////////////////////////////////////////////
- (void)useNewBundle:(XrayBundle *)new_bundle {
	[model setCurrentBundle:new_bundle];
	[operations_window_controller performSelectorOnMainThread:@selector(setBundle:)
												   withObject:new_bundle
												waitUntilDone:YES];
	[detector_1_image_window_controller performSelectorOnMainThread:@selector(setCurrentBundle:)
														 withObject:new_bundle
													  waitUntilDone:YES];	
	[detector_2_image_window_controller performSelectorOnMainThread:@selector(setCurrentBundle:)
														 withObject:new_bundle
													  waitUntilDone:YES];
}	

- (void)updateStateFired:(NSTimer *)the_timer {
	// to MainWindow
#if XRAY_DEVICES_ATTACHED
	[main_window_controller setSource1Voltage_kV:[[daq source1Voltage] floatValue]/1000];
	[main_window_controller setSource2Voltage_kV:[[daq source2Voltage] floatValue]/1000];
	[main_window_controller setSource1Current_mA:[[daq source1Current] floatValue]*1000];
	[main_window_controller setSource2Current_mA:[[daq source2Current] floatValue]*1000];
#else
	[main_window_controller setSource1Voltage_kV:(rand()*MAX_XRAY_VOLTAGE/RAND_MAX)/1000];
	[main_window_controller setSource2Voltage_kV:(rand()*MAX_XRAY_VOLTAGE/RAND_MAX)/1000];
	[main_window_controller setSource1Current_mA:(rand()*MAX_XRAY_CURRENT/RAND_MAX)*1000];
	[main_window_controller setSource2Current_mA:(rand()*MAX_XRAY_CURRENT/RAND_MAX)*1000];
#endif
}

- (NSData *)rawDataForDetector:(Detector)detector {
#if XRAY_DEVICES_ATTACHED
	switch(detector) {
		case DETECTOR_1:
			return [detector_1 rawImage];
			break;
		case DETECTOR_2:
			return [detector_2 rawImage];
			break;
		default:
			[NSException raise:NSInternalInconsistencyException 
						format:@"illegal detector number for [XRayBoxController rawDataForDetector:]"];
			return nil;
			break;
	}
#else
	//	NSString *xray_bundle_path = @"/Users/bkennedy/Desktop/calibrationObject1-20071015-161706.xry"];
	//NSString *xray_bundle_path = @"/Users/labuser/Desktop/Mack2-20080128-170005.xry";
//	NSString *xray_bundle_path = @"/Users/labuser/Desktop/black.xry";
//	NSString *xray_bundle_path = @"/Users/bkennedy/Desktop/Mack2-20080128-170005.xry";
	
	NSString *xray_bundle_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TestData_PapanastassiouPlasticValence.xry"];
	
switch(detector) {
	case DETECTOR_1:
		return [NSData dataWithContentsOfFile:[xray_bundle_path stringByAppendingPathComponent:@"/Image_processing/d1.raw"]];
		break;
	case DETECTOR_2:
		return [NSData dataWithContentsOfFile:[xray_bundle_path stringByAppendingPathComponent:@"/Image_processing/d2.raw"]];
		//			return [[[NSData alloc] initWithContentsOfFile:@"/Users/bkennedy/Desktop/TEST1-20071105-115809.xry/Image_processing/d1.raw"] autorelease];
		//			return [[[NSData alloc] initWithBytes:self 
		//										   length:2048000] autorelease];
		break;
	default:
		[NSException raise:NSInternalInconsistencyException 
					format:@"illegal detector number for [XRayBoxController rawDataForDetector:]"];
		return nil;
		break;
}	
#endif
}



@end

