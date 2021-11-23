//
//  Calibration.h
//  XRayBox
//
//  Created by Ben Kennedy on 2/12/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SourceDetectorPair.h"


@interface Calibration : NSObject {
	NSString *name;
	NSDate *date;

	NSArray *sdps;

	// guess
	float guess_rotation_spread;
	NSArray *guess_detector_distances;
	NSArray *guess_source_distances;
	
	NSData *calibration_mat_file_contents;
}

- (id)initWithFile:(NSString *)calibration_file;
+ (id)calibrationWithFile:(NSString *)calibration_file;

- (NSString *)name;
- (NSDate *)date;
- (NSArray *)sourceDetectorPairs;
- (float)guessRotationSpread;
- (NSArray *)guessDetectorDistances;
- (NSArray *)guessSourceDistances;
- (void)write:(NSString *)path;

@end
