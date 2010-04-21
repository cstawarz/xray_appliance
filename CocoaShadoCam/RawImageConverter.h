//
//  RawImageConverter.h
//  CocoaShadoCam
//
//  Created by Ben Kennedy on 10/26/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RawImageConverter : NSObject {

}

+ (NSBitmapImageRep *)convertRawToImage:(NSData *)raw_data
							 withMaxLUT:(unsigned short)max_LUT
							 withMinLUT:(unsigned short)min_LUT
						andSerialNumber:(NSString *)serial_number
						usingCorrection:(BOOL)should_calibrate_image
					andUsingCalibration:(BOOL)should_calibrate_image;
+ (NSData *)correctRawImage:(NSData *)raw_data
				 onDetector:(NSString *)serial_number;
+ (NSData *)calibrateRawImage:(NSData *)raw_data 
				   onDetector:(NSString *)serial_number;

@end
