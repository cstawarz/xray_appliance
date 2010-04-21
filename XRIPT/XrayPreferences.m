//
//  XrayPreferences.m
//  XRIPT
//
//  Created by bkennedy on 3/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayPreferences.h"

#define XRIPT_MUTE @"XRIPT - Mute"
#define XRIPT_SUBJECT @"XRIPT - Subject"
#define XRIPT_EXPERIMENTER @"XRIPT - Experimenter"
#define XRIPT_DETECTOR_LAG @"XRIPT - Detector Lag (s)"
#define XRIPT_SAVE_LOCATION @"XRIPT - Save Location"
#define XRIPT_SESSION_COMMENT @"XRIPT - Session Comment"
#define XRIPT_IMAGE_COMMENT @"XRIPT - Image Comment"
#define XRIPT_VOLTAGE_TO_REACH @"XRIPT - Voltage to reach (V)"
#define XRIPT_CURRENT_TO_REACH @"XRIPT - Current to reach (A)"
#define XRIPT_INTEGRATION_TIME @"XRIPT - Integration time (s)"
#define XRIPT_FIDUCIAL_CENTER_DETECTION_WINDOW @"XRIPT - center dectector window"


@implementation XrayPreferences

- (id)init {
	self = [super init];
	if(self != nil) {
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		
		[self setSoundOn:[ud integerForKey:XRIPT_MUTE]];
		[self setSubject:[ud stringForKey:XRIPT_SUBJECT]];
		[self setExperimenter:[ud stringForKey:XRIPT_EXPERIMENTER]];
		[self setDetectorLag:[ud floatForKey:XRIPT_DETECTOR_LAG]];
		[self setSaveLocation:[ud stringForKey:XRIPT_SAVE_LOCATION]];
		[self setSessionComment:[ud stringForKey:XRIPT_SESSION_COMMENT]];
		[self setImageComment:[ud stringForKey:XRIPT_IMAGE_COMMENT]];
		[self setMaxVoltage:[ud floatForKey:XRIPT_VOLTAGE_TO_REACH]];
		[self setMaxCurrent:[ud floatForKey:XRIPT_CURRENT_TO_REACH]];
		[self setIntegrationTime:[ud floatForKey:XRIPT_INTEGRATION_TIME]];
		[self setCenterFinderWindowSize:[ud integerForKey:XRIPT_FIDUCIAL_CENTER_DETECTION_WINDOW]];
		
		calibration = nil;			
		[self setCalibrationMessage:@"No calibration"];
	}
	return self;
}

- (void)saveAsDefaults {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	[ud setInteger:sound_on forKey:XRIPT_MUTE];
	[ud setObject:subject forKey:XRIPT_SUBJECT];
	[ud setObject:experimenter forKey:XRIPT_EXPERIMENTER];
	[ud setFloat:detector_lag forKey:XRIPT_DETECTOR_LAG];
	[ud setObject:save_location forKey:XRIPT_SAVE_LOCATION];
	[ud setObject:session_comment forKey:XRIPT_SESSION_COMMENT];
	[ud setObject:image_comment forKey:XRIPT_IMAGE_COMMENT];
	[ud setFloat:max_voltage forKey:XRIPT_VOLTAGE_TO_REACH];
	[ud setFloat:max_current forKey:XRIPT_CURRENT_TO_REACH];
	[ud setFloat:integration_time forKey:XRIPT_INTEGRATION_TIME];
	[ud setInteger:center_finder_window_size forKey:XRIPT_FIDUCIAL_CENTER_DETECTION_WINDOW];
	
	[ud synchronize];
}

- (void)dealloc {
	[subject release];
	[image_comment release];
	[experimenter release];
	[session_comment release];
	[save_location release];
	[calibration release];
	
	[super dealloc];
}

///////////////////////////////////////////////
/////// Accessor methods
///////////////////////////////////////////////
// MAX XRAY SOURCE PARAMETERS
- (float)maxVoltage {return max_voltage;}
- (void)setMaxVoltage:(float)new_max_voltage {max_voltage = new_max_voltage;}
- (float)maxCurrent {return max_current;}
- (void)setMaxCurrent:(float)new_max_current {max_current = new_max_current;}

	// sound
- (int)soundOn {return sound_on;}
- (void)setSoundOn:(int)new_sound_on {sound_on = new_sound_on;}

	// various strings
- (NSString *)subject {return subject;}
- (void)setSubject:(NSString *)new_subject {
	[subject release];
	subject = [new_subject copy];
}

- (NSString *)imageComment {return image_comment;}
- (void)setImageComment:(NSString *)new_image_comment {
	[image_comment release];
	image_comment = [new_image_comment copy];	
}

- (NSString *)sessionComment {return session_comment;}
- (void)setSessionComment:(NSString *)new_session_comment {
	[session_comment release];
	session_comment = [new_session_comment copy];	
}
- (NSString *)experimenter {return experimenter;}
- (void)setExperimenter:(NSString *)new_experimenter {
	[experimenter release];
	experimenter = [new_experimenter copy];
}

- (NSString *)saveLocation {return save_location;}
- (void)setSaveLocation:(NSString *)new_save_location {
	[save_location release];
	save_location = [new_save_location copy];
}

	// current calibration
- (Calibration *)calibration {return calibration;}
- (void)setCalibration:(Calibration *)new_calibration {
	[calibration release];
	calibration = [new_calibration retain];
	
	if (calibration != nil) {
		[self setCalibrationMessage:[[calibration date] descriptionWithCalendarFormat:@"Last Calibrated: %d %b, %Y"
																			 timeZone:nil 
																			   locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
	} else {
		[self setCalibrationMessage:@"No calibration"];
	}
}

- (NSString *)calibrationMessage {return calibration_message;}
- (void)setCalibrationMessage:(NSString *)new_calibration_message {
	[calibration_message release];
	calibration_message = [new_calibration_message copy];
}


	// center finder size
- (int)centerFinderWindowSize {return center_finder_window_size;}
- (void)setCenterFinderWindowSize:(int)new_center_finder_window_size {
	center_finder_window_size=new_center_finder_window_size;
}

- (NSTimeInterval)detectorLag {return detector_lag;}
- (void)setDetectorLag:(NSTimeInterval)new_detector_lag {
	detector_lag=new_detector_lag;
}

- (NSTimeInterval)integrationTime { return integration_time; }
- (void)setIntegrationTime:(NSTimeInterval)new_integration_time {
	integration_time = new_integration_time;
}

//@synthesize subject=subject, imageComment=image_comment, experimenter=experimenter, sessionComment=session_comment, saveLocation=save_location;
//@synthesize detectorLag=detector_lag, integrationTime=integration_time;
//@synthesize maxVoltage=max_voltage, maxCurrent=max_current;
//@synthesize soundOn=sound_on;
//@synthesize calibration=calibration;
//@synthesize centerFinderWindowSize=center_finder_window_size;
//@synthesize statusMessage=status_message;

- (NSString *)nfsPath {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NFS"];	
}

- (NSString *)fforPath {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FFOR"];	
}

@end
