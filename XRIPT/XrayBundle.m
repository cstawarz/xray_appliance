//
//  XRayBundle.m
//  XRayBox
//
//  Created by Ben Kennedy on 8/1/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import "XrayBundle.h"
#import "XrayXMLDocument.h"
#import "XrayBundleMATLABInterface.h"

@interface XrayBundle(PrivateMethods)
- (void)writeBundle:(NSXMLElement *)root;
@end

@implementation XrayBundle

- (id) initWithSubject:(NSString *)_subject
	   andExperimenter:(NSString *)_experimenter
andDetector1SerialNumber:(NSString *)_d1_serial_number
andDetector2SerialNumber:(NSString *)_d2_serial_number
andDetector1ExposureTime:(NSTimeInterval)_detector_1_exposure_time
andDetector2ExposureTime:(NSTimeInterval)_detector_2_exposure_time
	 andSource1Voltage:(float)_source1Voltage_V
	 andSource2Voltage:(float)_source2Voltage_V
	 andSource1Current:(float)_source1Current_A
	 andSource2Current:(float)_source2Current_A
	   andDetector1Lag:(NSTimeInterval)_detector1Lag
	   andDetector2Lag:(NSTimeInterval)_detector2Lag
	andSource1Duration:(NSTimeInterval)_source1Duration
	andSource2Duration:(NSTimeInterval)_source2Duration
	   andImageComment:(NSString *)_image_comment
	 andSessionComment:(NSString *)_session_comment
				 andD1:(NSData *)_d1_image
				 andD2:(NSData *)_d2_image
			  andD1Raw:(NSData *)_d1_raw_data
			  andD2Raw:(NSData *)_d2_raw_data
		andCalibration:(Calibration *)_calibration
		andXrayElements:(NSArray *)_xray_elements {
	self = [super init];
	if (self != nil) {
		bundle_lock = [[NSLock alloc] init];

		path = nil;
		
		date=[[NSDate alloc] init];
		subject=[_subject copy];
		experimenter=[_experimenter copy];
		d1_serial_number = [_d1_serial_number copy];
		d2_serial_number = [_d2_serial_number copy];
		d1_exposure_duration=_detector_1_exposure_time;
		s1_voltage=_source1Voltage_V;
		s1_current=_source1Current_A;
		d1_lag=_detector1Lag;
		s1_duration=_source1Duration;
		d2_exposure_duration=_detector_2_exposure_time;
		s2_voltage=_source2Voltage_V;
		s2_current=_source2Current_A;
		d2_lag=_detector2Lag;
		s2_duration=_source2Duration;
		session_comment=[_session_comment copy];
		image_comment=[_image_comment copy];
		d1_image = [_d1_image copy];
		d2_image = [_d2_image copy];
		d1_raw_data = [_d1_raw_data copy];
		d2_raw_data = [_d2_raw_data copy];
		calibration = _calibration;
		
		xray_elements = _xray_elements;
		
	}
	return self;
}

+ (id)bundleWithSubject:(NSString *)_subject
		andExperimenter:(NSString *)_experimenter
andDetector1SerialNumber:(NSString *)_d1_serial_number
andDetector2SerialNumber:(NSString *)_d2_serial_number
andDetector1ExposureTime:(NSTimeInterval)_detector_1_exposure_time
andDetector2ExposureTime:(NSTimeInterval)_detector_2_exposure_time
	  andSource1Voltage:(float)_source1Voltage_V
	  andSource2Voltage:(float)_source2Voltage_V
	  andSource1Current:(float)_source1Current_A
	  andSource2Current:(float)_source2Current_A
		andDetector1Lag:(NSTimeInterval)_detector1Lag
		andDetector2Lag:(NSTimeInterval)_detector2Lag
	 andSource1Duration:(NSTimeInterval)_source1Duration
	 andSource2Duration:(NSTimeInterval)_source2Duration
		andImageComment:(NSString *)_image_comment
	  andSessionComment:(NSString *)_session_comment
				  andD1:(NSData *)_d1_image
				  andD2:(NSData *)_d2_image
			   andD1Raw:(NSData *)_d1_raw_data
			   andD2Raw:(NSData *)_d2_raw_data
		 andCalibration:(Calibration *)_calibration
		 andXrayElements:(NSArray *)_xray_elements {	
	return [[self alloc] initWithSubject:_subject
						  andExperimenter:_experimenter
				 andDetector1SerialNumber:_d1_serial_number
				 andDetector2SerialNumber:_d2_serial_number
				 andDetector1ExposureTime:_detector_1_exposure_time
				 andDetector2ExposureTime:_detector_2_exposure_time
						andSource1Voltage:_source1Voltage_V
						andSource2Voltage:_source2Voltage_V
						andSource1Current:_source1Current_A
						andSource2Current:_source2Current_A
						  andDetector1Lag:_detector1Lag
						  andDetector2Lag:_detector2Lag
					   andSource1Duration:_source1Duration
					   andSource2Duration:_source2Duration
						  andImageComment:_image_comment
						andSessionComment:_session_comment
									andD1:_d1_image
									andD2:_d2_image
								 andD1Raw:_d1_raw_data
								 andD2Raw:_d2_raw_data
						   andCalibration:_calibration
						   andXrayElements:_xray_elements];
}


- (id)initFromPath:(NSString *)bundle_path {
	self = [super init];
	if (self != nil) {
		bundle_lock = [[NSLock alloc] init];
		
		
		// this can get filled in later
		NSURL *xml_location = [NSURL fileURLWithPath:[bundle_path stringByAppendingPathComponent:@"info.xml"]];
		
		XrayXMLDocument *doco = [[XrayXMLDocument alloc] initWithContentsOfURL:xml_location
																	   options:0
																		 error:nil];
		if(doco == nil) {
			[NSException raise:NSInternalInconsistencyException
						format:@"[XRayBundle initFromPath:] couldn't open xml doc %@",
				@"XML file"];
		}
		
		NSString *date_string = [doco valueStringForSingularXPath:@"./info/Date"];
		NSString *YYYY = [date_string substringWithRange:NSMakeRange(0,4)];
		NSString *MMonth = [date_string substringWithRange:NSMakeRange(5,2)];
		NSString *DD = [date_string substringWithRange:NSMakeRange(8,2)];

		NSString *time_string = [doco valueStringForSingularXPath:@"./info/Time"];
		NSString *HH = [time_string substringWithRange:NSMakeRange(0,2)];
		NSString *MMinute = [time_string substringWithRange:NSMakeRange(3,2)];
		NSString *SS = [time_string substringWithRange:NSMakeRange(6,2)];
		NSString *HHMM = @"-0500";
		NSString *standard_time_string = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ %@",
			YYYY, MMonth, DD, HH, MMinute, SS, HHMM];
		date = [[NSDate alloc] initWithString:standard_time_string];
		
		subject = [[doco valueStringForSingularXPath:@"./info/Subject"] copy];
		experimenter = [[doco valueStringForSingularXPath:@"./info/Experimenter"] copy];
		d1_serial_number = [[doco valueStringForSingularXPath:@"./info/Detector_ID/Detector_1"] copy];	
		d1_exposure_duration = [[doco valueStringForSingularXPath:@"./info/Exposure_Time/Detector_1"] doubleValue]/1000;
		s1_voltage = [[doco valueStringForSingularXPath:@"./info/Voltage/Source_1"] doubleValue];
		s1_current = [[doco valueStringForSingularXPath:@"./info/Current/Source_1"] doubleValue];
		d1_lag = [[doco valueStringForSingularXPath:@"./info/Lag_Time/Detector_1"] doubleValue]/1000;
		s1_duration = [[doco valueStringForSingularXPath:@"./info/Source_Time/Source_1"] doubleValue]/1000;
		d1_raw_data = [[NSData alloc] initWithContentsOfFile:[bundle_path stringByAppendingPathComponent:@"Image_processing/d1.raw"]];
		NSImage *d1 = [[NSImage alloc] initWithContentsOfFile:[bundle_path stringByAppendingPathComponent:@"D1.tif"]];
		d1_image = [[d1 TIFFRepresentation] copy];
		
		d2_serial_number = [[doco valueStringForSingularXPath:@"./info/Detector_ID/Detector_2"] copy];	
		d2_exposure_duration = [[doco valueStringForSingularXPath:@"./info/Exposure_Time/Detector_2"] doubleValue]/1000;
		s2_voltage = [[doco valueStringForSingularXPath:@"./info/Voltage/Source_2"] doubleValue];
		s2_current = [[doco valueStringForSingularXPath:@"./info/Current/Source_2"] doubleValue];
		d2_lag = [[doco valueStringForSingularXPath:@"./info/Lag_Time/Detector_2"] doubleValue]/1000;
		s2_duration = [[doco valueStringForSingularXPath:@"./info/Source_Time/Source_2"] doubleValue]/1000;
		d2_raw_data = [[NSData alloc] initWithContentsOfFile:[bundle_path stringByAppendingPathComponent:@"Image_processing/d2.raw"]];
		NSImage *d2 = [[NSImage alloc] initWithContentsOfFile:[bundle_path stringByAppendingPathComponent:@"D2.tif"]];
		d2_image = [[d2 TIFFRepresentation] copy];
		
		image_comment = [[doco valueStringForSingularXPath:@"./info/Image_Comment"] copy];
		session_comment = [[doco valueStringForSingularXPath:@"./info/Session_Comment"] copy];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:[bundle_path stringByAppendingPathComponent:@"calibration/calibration.mat"]]) {
			calibration = [Calibration calibrationWithFile:[bundle_path stringByAppendingPathComponent:@"calibration/calibration.mat"]];
		} else {
			calibration = nil;
		}
		
		xray_elements = [[NSArray alloc] initWithArray:[XrayBundleMATLABInterface xrayElementsFromBundle:bundle_path]];
		
		path = [bundle_path copy];
	}
	return self;
}


+ (id)bundleAtPath:(NSString *)bundle_path {
	return [[self alloc] initFromPath:bundle_path];
}


- (void)writeBundleTo:(NSString *)_path {
	path = [[_path stringByAppendingPathComponent:[self name]] copy];
	
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"info"];
	
	{
		NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		
		NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, buildVersion];
		
		
		NSXMLElement *XML_appVersion = [[NSXMLElement alloc] initWithName:@"ApplicationVersion" 
															   stringValue:appVersion];
		
		[root addChild:XML_appVersion];
	}
	
	{
		NSXMLElement *XML_date = [[NSXMLElement alloc] initWithName:@"Date" 
														 stringValue:[date descriptionWithCalendarFormat:@"%Y-%m-%d"
																								timeZone:nil 
																								  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
		[root addChild:XML_date];
	}
	
	{
		NSXMLElement *XML_time = [[NSXMLElement alloc] initWithName:@"Time" 
														 stringValue:[date descriptionWithCalendarFormat:@"%H:%M:%S"
																								timeZone:nil 
																								  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
		[root addChild:XML_time];
	}
	
	{
		NSXMLElement *XML_subject = [[NSXMLElement alloc] initWithName:@"Subject" 
															stringValue:subject];
		[root addChild:XML_subject];
	}
	
	{
		NSXMLElement *XML_experimenter = [[NSXMLElement alloc] initWithName:@"Experimenter" 
																 stringValue:experimenter];
		[root addChild:XML_experimenter];
	}
	
	
	
	// detector serial numbers
	{
		NSXMLElement *XML_serialNumbers = [[NSXMLElement alloc] initWithName:@"Detector_ID"];
		NSXMLElement *XML_d1_serial_number = [[NSXMLElement alloc] initWithName:@"Detector_1" 
																	 stringValue:[self detector1SerialNumber]];
		[XML_serialNumbers addChild:XML_d1_serial_number];
		
		NSXMLElement *XML_d2_serial_number = [[NSXMLElement alloc] initWithName:@"Detector_2" 
																	 stringValue:[self detector2SerialNumber]];
		[XML_serialNumbers addChild:XML_d2_serial_number];
		
		
		[root addChild:XML_serialNumbers];
	}
	
	// detector exposure time
	{
		NSXMLElement *XML_exposureTime = [[NSXMLElement alloc] initWithName:@"Exposure_Time"];
		NSXMLElement *XML_d1ExposureTime = [[NSXMLElement alloc] initWithName:@"Detector_1" 
																   stringValue:[[NSNumber numberWithFloat:[self detector1ExposureDuration]*1000] stringValue]];
		[XML_d1ExposureTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_exposureTime addChild:XML_d1ExposureTime];
		
		NSXMLElement *XML_d2ExposureTime = [[NSXMLElement alloc] initWithName:@"Detector_2" 
																   stringValue:[[NSNumber numberWithFloat:[self detector2ExposureDuration]*1000] stringValue]];
		[XML_d2ExposureTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_exposureTime addChild:XML_d2ExposureTime];
		
		[root addChild:XML_exposureTime];
	}
	
	// source voltage
	{
		NSXMLElement *XML_voltage = [[NSXMLElement alloc] initWithName:@"Voltage"];
		NSXMLElement *XML_s1Voltage = [[NSXMLElement alloc] initWithName:@"Source_1" 
															  stringValue:[[NSNumber numberWithFloat:[self source1Voltage]] stringValue]];
		[XML_s1Voltage addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"V"]];
		[XML_voltage addChild:XML_s1Voltage];
		
		NSXMLElement *XML_s2Voltage = [[NSXMLElement alloc] initWithName:@"Source_2" 
															  stringValue:[[NSNumber numberWithFloat:[self source2Voltage]] stringValue]];
		[XML_s2Voltage addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"V"]];
		[XML_voltage addChild:XML_s2Voltage];
		
		[root addChild:XML_voltage];
	}
	
	// source current
	{
		NSXMLElement *XML_current = [[NSXMLElement alloc] initWithName:@"Current"];
		NSXMLElement *XML_s1Current = [[NSXMLElement alloc] initWithName:@"Source_1" 
															  stringValue:[[NSNumber numberWithFloat:[self source1Current]] stringValue]];
		[XML_s1Current addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"A"]];
		[XML_current addChild:XML_s1Current];
		
		NSXMLElement *XML_s2Current = [[NSXMLElement alloc] initWithName:@"Source_2" 
															  stringValue:[[NSNumber numberWithFloat:[self source2Current]] stringValue]];
		[XML_s2Current addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"A"]];
		[XML_current addChild:XML_s2Current];
		
		[root addChild:XML_current];
	}
	
	// detector lag
	{
		NSXMLElement *XML_lagTime = [[NSXMLElement alloc] initWithName:@"Lag_Time"];
		NSXMLElement *XML_d1lagTime = [[NSXMLElement alloc] initWithName:@"Detector_1" 
															  stringValue:[[NSNumber numberWithFloat:[self detector1Lag]*1000] stringValue]];
		[XML_d1lagTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_lagTime addChild:XML_d1lagTime];
		
		NSXMLElement *XML_d2lagTime = [[NSXMLElement alloc] initWithName:@"Detector_2" 
															  stringValue:[[NSNumber numberWithFloat:[self detector2Lag]*1000] stringValue]];
		[XML_d2lagTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_lagTime addChild:XML_d2lagTime];
		
		[root addChild:XML_lagTime];
	}
	
	// source duration
	{
		NSXMLElement *XML_durationTime = [[NSXMLElement alloc] initWithName:@"Source_Time"];
		NSXMLElement *XML_s1durationTime = [[NSXMLElement alloc] initWithName:@"Source_1" 
																   stringValue:[[NSNumber numberWithFloat:[self source1Duration]*1000] stringValue]];
		[XML_s1durationTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_durationTime addChild:XML_s1durationTime];
		
		NSXMLElement *XML_s2durationTime = [[NSXMLElement alloc] initWithName:@"Source_2" 
																   stringValue:[[NSNumber numberWithFloat:[self source2Duration]*1000] stringValue]];
		[XML_s2durationTime addAttribute:[NSXMLNode attributeWithName:@"units" stringValue:@"ms"]];
		[XML_durationTime addChild:XML_s2durationTime];
		
		[root addChild:XML_durationTime];
	}
	
	// image comment
	{
		NSXMLElement *XML_comment = [[NSXMLElement alloc] initWithName:@"Image_Comment" 
															stringValue:[self imageComment]];
		[root addChild:XML_comment];
	}
	
	// session comment
	{
		NSXMLElement *XML_comment = [[NSXMLElement alloc] initWithName:@"Session_Comment" 
															stringValue:[self sessionComment]];
		[root addChild:XML_comment];
	}
	
	[self performSelectorOnMainThread:@selector(writeBundle:)
						   withObject:root
						waitUntilDone:YES];
	
}

- (NSString *)name {
	return [subject stringByAppendingString:[date descriptionWithCalendarFormat:@"-%Y%m%d-%H%M%S.xry"
																	   timeZone:nil 
																		 locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
}

- (void)writeImages:(id)arg {
	if(path != nil) {
		[[self imageForDetector:DETECTOR_1] writeToFile:[path stringByAppendingPathComponent:@"D1.tif"]
												options:0
												  error:nil];
		[[self imageForDetector:DETECTOR_2] writeToFile:[path stringByAppendingPathComponent:@"D2.tif"]
												options:0
												  error:nil];
	}
}

- (void)writeXrayElements {
	const int SAVE_TO_MATLAB=1;
	
	if(path != nil && SAVE_TO_MATLAB) {
		[XrayBundleMATLABInterface write:[self xrayElements] toBundle:path];
	}
}

- (float)source1Voltage {return s1_voltage;}
- (float)source2Voltage {return s2_voltage;}
- (float)source1Current {return s1_current;}
- (float)source2Current {return s2_current;}
- (NSTimeInterval)detector1Lag {return d1_lag;}
- (NSTimeInterval)source1Duration {return s1_duration;}
- (NSTimeInterval)detector1ExposureDuration {return d1_exposure_duration;}
- (NSTimeInterval)detector2Lag {return d2_lag;}
- (NSTimeInterval)source2Duration {return s2_duration;}
- (NSTimeInterval)detector2ExposureDuration {return d2_exposure_duration;}
- (NSString *)subject {return subject;}
- (NSString *)experimenter {return experimenter;}
- (NSString *)detector1SerialNumber {return d1_serial_number;}
- (NSString *)detector2SerialNumber {return d2_serial_number;}
- (NSString *)imageComment {return image_comment;}
- (NSString *)sessionComment {return session_comment;}
- (NSString *)path {return path;}
- (NSData *)detector1RawData {return d1_raw_data;}
- (NSData *)detector2RawData {return d2_raw_data;}
- (Calibration *)calibration {return calibration;}


- (NSData *)imageForDetector:(Detector)detector {
	[bundle_lock lock];
	
	NSData *image = nil;
	switch(detector) {
		case DETECTOR_1:
			image = d1_image;
			break;
		case DETECTOR_2:
			image = d2_image;
			break;
		default:
			break;
	}
	
	[bundle_lock unlock];
	return image;
}
- (void)setImage:(NSData *)new_image
	 forDetector:(Detector)detector {
	[bundle_lock lock];	
	switch(detector) {
		case DETECTOR_1:
			d1_image;
			d1_image = [new_image copy];
			break;
		case DETECTOR_2:
			d2_image;
			d2_image = [new_image copy];
			break;
		default:
			break;
	}	
	[bundle_lock unlock];
}

//- (NSData *)detector1Image {
//	[bundle_lock lock];
//	[d1_image retain];
//	[bundle_lock unlock];
//	return [d1_image autorelease];
//}
//- (void)setDetector1Image:(NSData *)new_detector_1_image {
//	[bundle_lock lock];
//	[d1_image release];
//	d1_image = [new_detector_1_image copy];
//	[bundle_lock unlock];
//}
//
//- (NSData *)detector2Image {
//	[bundle_lock lock];
//	[d2_image retain];
//	[bundle_lock unlock];
//	return [d2_image autorelease];
//}
//- (void)setDetector2Image:(NSData *)new_detector_2_image {
//	[bundle_lock lock];
//	[d2_image release];
//	d2_image = [new_detector_2_image copy];
//	[bundle_lock unlock];
//}

- (NSArray *)xrayElements {
	[bundle_lock lock];
	[bundle_lock unlock];
	return xray_elements;
}
- (void)setXrayElements:(NSArray *)new_xray_elements {
	[bundle_lock lock];
	xray_elements = new_xray_elements;
	[bundle_lock unlock];
	[self writeXrayElements];
}

//////////////////////////////////////////////////////////////////////////////
// Private Methods
//////////////////////////////////////////////////////////////////////////////
- (void)writeBundle:(NSXMLElement *)root {	
	NSFileManager *dfm = [NSFileManager defaultManager];	
	BOOL isDirectory;
	
	if(![dfm fileExistsAtPath:[path stringByDeletingLastPathComponent]
				  isDirectory:&isDirectory]) {
		return;
	}
	
	if(!isDirectory) {
		return;
	}
	
	
	if(!([dfm createDirectoryAtPath:path attributes:nil] &&
		 [dfm createDirectoryAtPath:[path stringByAppendingPathComponent:@"Image_processing"] attributes:nil] &&
		 [dfm createDirectoryAtPath:[path stringByAppendingPathComponent:@"3D_reconstruction"] attributes:nil])) {
		return;
	}
	
	[[self detector1RawData] writeToFile:[path stringByAppendingPathComponent:@"Image_processing/d1.raw"]
								 options:0
								   error:nil];
	[[self detector2RawData] writeToFile:[path stringByAppendingPathComponent:@"Image_processing/d2.raw"]
								 options:0
								   error:nil];
	
	[self writeImages:nil];
	[self writeXrayElements];
	
	
	if(calibration != nil) {
		[dfm createDirectoryAtPath:[path stringByAppendingPathComponent:@"Calibration"]
						attributes:nil];
		
		[calibration write:[path stringByAppendingPathComponent:@"Calibration"]];
	}
	
	
	NSXMLDocument *doco = [[NSXMLDocument alloc] initWithRootElement:root];
	
	[[doco XMLDataWithOptions:NSXMLNodePrettyPrint] writeToFile:[path stringByAppendingPathComponent:@"info.xml"]
														options:0
														  error:nil];
}



//	@synthesize subject=subject, experimenter=experimenter, comment=comment;
//	@synthesize detector1RawData=d1_raw_data, detector1Image=d1_image, detector1SerialNumber=d1_serial_number;
//	@synthesize source1Voltage=s1_voltage, source1Current=s1_current;
//	@synthesize detector1Image=d1_image, detector1RawData=d1_raw_data;
//	@synthesize detector1Lag=d1_lag, detector1ExposureDuration=d1_exposure_duration, source1Duration=s1_duration;
//	@synthesize detector2RawData=d2_raw_data, detector2Image=d2_image, detector2SerialNumber=d2_serial_number;
//	@synthesize source2Voltage=s2_voltage, source2Current=s2_current;
//	@synthesize detector2Lag=d2_lag, detector2ExposureDuration=d2_exposure_duration, source2Duration=s2_duration;
//	@synthesize detector2Image=d2_image, detector2RawData=d2_raw_data;
//	@synthesize xrayElements=xray_elements, path=path, calibration=calibration;

@end
