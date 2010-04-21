//
//  XrayPreferences.h
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Calibration.h"

@interface XrayPreferences : NSObject {
	NSString *subject;
	NSString *image_comment;
	NSString *experimenter;
	NSString *session_comment;
	NSString *save_location;
	NSString *calibration_message;
	float max_voltage;
	float max_current;
	NSTimeInterval detector_lag;
	NSTimeInterval integration_time;
	int sound_on;
	Calibration *calibration;
	int center_finder_window_size;
}

- (void)saveAsDefaults;

// TIMES
- (NSTimeInterval)detectorLag;
- (void)setDetectorLag:(NSTimeInterval)new_detector_lag;
- (NSTimeInterval)integrationTime;
- (void)setIntegrationTime:(NSTimeInterval)new_integration_time;

	///////////////////////////////////////////////
	/////// Accessor methods
	///////////////////////////////////////////////
	// MAX XRAY SOURCE PARAMETERS
- (float)maxVoltage;
- (void)setMaxVoltage:(float)new_max_voltage;
- (float)maxCurrent;
- (void)setMaxCurrent:(float)new_max_current;

	// sound
- (int)soundOn;
- (void)setSoundOn:(int)new_sound_on;

	// directories of object paths
- (NSString *)nfsPath;
- (NSString *)fforPath;

	// various strings
- (NSString *)subject;
- (void)setSubject:(NSString *)new_subject;
- (NSString *)imageComment;
- (void)setImageComment:(NSString *)new_image_comment;
- (NSString *)sessionComment;
- (void)setSessionComment:(NSString *)new_session_comment;
- (NSString *)experimenter;
- (void)setExperimenter:(NSString *)new_experimenter;
- (NSString *)saveLocation;
- (void)setSaveLocation:(NSString *)new_save_location;
- (NSString *)calibrationMessage;
- (void)setCalibrationMessage:(NSString *)new_calibration_message;

	// current calibration
- (Calibration *)calibration;
- (void)setCalibration:(Calibration *)new_calibration;

	// center finder size
- (int)centerFinderWindowSize;
- (void)setCenterFinderWindowSize:(int)new_center_finder_window_size;


@end
