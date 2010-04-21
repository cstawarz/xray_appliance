//
//  ShadoCam.h
//  CocoaShadoCam
//
//  Created by Ben Kennedy on 9/14/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define TM_INTERNAL '0' 
#define	TM_EXTERNAL '1'
#define	TM_INTERNAL_TRIGGER '2'
#define TM_EXTERNAL_TRIGGER '3'


@interface ShadoCam : NSObject {
	NSString *device_path;
	NSString *volume_path;
	
	NSData *raw_image;
	NSData *raw_offset;

	NSString *serial_number;
	bool ValidImage;
	bool ValidOffset;
	bool ValidPixmap;
	bool OffsetCorr;
	bool PixelCorr;
	short ImageScale;
	short OffsetScale;
	bool RESET;
	bool BIN;
	bool NDR;
	unsigned long IntTime;
	char TimingMode;
}

- (id)initWithPath:(NSString *)thePath;

- (NSString *)serialNumber;
- (NSString *)volumePath;
- (NSString *)devicePath;
- (void)setIntegrationTime:(NSTimeInterval)time_s;
- (void)setTimingMode:(char)tm;
- (void)setImageGain:(char)ig;
- (void)setOffsetGain:(char)og;
- (void)setOffsetCorrection:(int)oc;
- (void)setReset:(char)reset;

- (BOOL)pollUntilImageReady:(int)maxAttempts;
- (BOOL)pollUntilCameraReady:(int)maxAttempts;

- (BOOL)validImage;
- (BOOL)validOffset;
- (BOOL)validPixmap;
- (BOOL)offsetCorr;
- (BOOL)pixelCorr;
- (short)imageScale;
- (short)offsetScale;
- (BOOL)isReset;
- (BOOL)bin;
- (BOOL)ndr;
- (NSTimeInterval)integrationTime;
- (short)timingMode;
- (NSData *)rawImage;
- (NSData *)rawOffset;


@end
