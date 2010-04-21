//
//  XrayBundle.h
//  XRayBox
//
//  Created by Ben Kennedy on 8/1/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Calibration.h"
#import "XrayObject.h"


@interface XrayBundle : NSObject {
	// goes in the info.xml file
	NSDate *date;
	NSString *subject;
	NSString *experimenter;
	NSString *d1_serial_number;
	NSString *d2_serial_number;
	NSTimeInterval d1_exposure_duration;
	float s1_voltage;
	float s1_current;
	NSTimeInterval d1_lag;
	NSTimeInterval s1_duration;
	NSTimeInterval d2_exposure_duration;
	float s2_voltage;
	float s2_current;
	NSTimeInterval d2_lag;
	NSTimeInterval s2_duration;
	NSString *image_comment;
	NSString *session_comment;
	
	// the images to put in the bundle
	NSData *d1_image;
	NSData *d2_image;
	
	// the raw data to put in the bundle
	NSData *d1_raw_data;
	NSData *d2_raw_data;
	
	Calibration *calibration;
	
	NSString *path;
	
	NSArray *xray_elements;
	
	NSLock *bundle_lock;
}

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
		andXrayElements:(NSArray *)_xray_elements;

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
		 andXrayElements:(NSArray *)_xray_elements;

- (id)initFromPath:(NSString *)bundle_path;
+ (id)bundleAtPath:(NSString *)bundle_path;

- (void)writeBundleTo:(NSString *)_path;
- (void)writeImages:(id)arg;
- (void)writeXrayElements;

- (float)source1Voltage;
- (float)source2Voltage;
- (float)source1Current;
- (float)source2Current;
- (NSTimeInterval)detector1Lag;
- (NSTimeInterval)source1Duration;
- (NSTimeInterval)detector1ExposureDuration;
- (NSTimeInterval)detector2Lag;
- (NSTimeInterval)source2Duration;
- (NSTimeInterval)detector2ExposureDuration;
- (NSString *)subject;
- (NSString *)experimenter;
- (NSString *)detector1SerialNumber;
- (NSString *)detector2SerialNumber;
- (NSString *)sessionComment;
- (NSString *)imageComment;
- (NSString *)name;
- (NSString *)path;
- (NSData *)detector1RawData;
- (NSData *)detector2RawData;
- (Calibration *)calibration;
- (NSData *)imageForDetector:(Detector)detector;
- (void)setImage:(NSData *)new_image forDetector:(Detector)detector;
//- (NSData *)detector1Image;
//- (void)setDetector1Image:(NSData *)new_detector_1_image;
//- (NSData *)detector2Image;
//- (void)setDetector2Image:(NSData *)new_detector_2_image;
- (NSArray *)xrayElements;
- (void)setXrayElements:(NSArray *)new_xray_elements;

//	@property (readonly) float source1Voltage;
//	@property (readonly) float source2Voltage;
//	@property (readonly) float source1Current;
//	@property (readonly) float source2Current;
//	@property (readonly) NSTimeInterval detector1Lag;
//	@property (readonly) NSTimeInterval source1Duration;
//	@property (readonly) NSTimeInterval detector1ExposureDuration;
//	@property (readonly) NSTimeInterval detector2Lag;
//	@property (readonly) NSTimeInterval source2Duration;
//	@property (readonly) NSTimeInterval detector2ExposureDuration;
//	@property (readonly) NSString *subject;
//	@property (readonly) NSString *experimenter;
//	@property (readonly) NSString *detector1SerialNumber;
//	@property (readonly) NSString *detector2SerialNumber;
//	@property (readonly) NSString *comment;
//	@property (readonly) NSString *name;
//	@property (readonly) NSString *path;
//	@property (readonly) NSData *detector1RawData;
//	@property (readonly) NSData *detector2RawData;
//	@property (readonly) Calibration *calibration;
//	@property (readwrite, copy) NSImage *detector1Image;
//	@property (readwrite, copy) NSImage *detector2Image;
//	@property (readwrite, retain) NSArray *xrayElements;
@end
