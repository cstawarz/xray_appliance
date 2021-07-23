//
//  ShadoCam.m
//  CocoaShadoCam
//
//  Created by Ben Kennedy on 9/14/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import "ShadoCam.h"
#import <unistd.h>
#include <sys/mount.h>


#define SERIAL_DEFAULT @"XXXX"
#define SETUP_FILE @"SETUP.TXT"
#define RAW_IMAGE_FILE @"IMAGE.RAW"
#define RAW_OFFSET_FILE @"OFFSET.RAW"

@interface ShadoCam(PrivateMethods)
- (void)writeData:(NSData *)data;
- (void)readSetupFileAndUpdateValues:(id)arg;
- (NSString *)discoverDevicePath;
- (void)updateDevice:(id)arg;
- (void)connect:(id)arg;
- (void)disconnect:(id)arg;
- (void)getRawImage:(id)arg;
- (void)getRawOffset:(id)arg;
@end

@implementation ShadoCam

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self != nil) {
		volume_path = [thePath copy];
		serial_number = [SERIAL_DEFAULT copy];
		device_path = [[self discoverDevicePath] copy];
		[self readSetupFileAndUpdateValues:nil];
	}
	return self;
}

- (void)dealloc {
	[serial_number release];
	[volume_path release];
	[device_path release];
	[super dealloc];
}

- (NSString *)serialNumber {
	return serial_number;
}

- (NSString *)volumePath {
	return volume_path;
}

- (NSString *)devicePath {
	return device_path;
}

//- (void)setIntegrationTime:(NSNumber *)time_us {
//	long counterTime = [time_us longValue]/512;
//	
//	if(counterTime >= 0xFFFF) {
//		// throw an exception
//	}
//	
//	char data[3];
//	data[0]=0x3B;
//	data[1]=(counterTime & 0xFF00) >> 8;
//	data[2]=counterTime & 0x00FF;
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:3]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}	
//
//- (void)setTimingMode:(NSNumber *)tm {
//	char timingMode = [tm charValue];
//	
//	char data[2];
//	data[0]=0x3E;
//	data[1]=timingMode; 
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:2]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}
//
//- (void)setImageGain:(NSNumber *)ig {
//	char imageGain = [ig charValue];
//	
//	char data[2];
//	data[0]=0x33;
//	data[1]=imageGain + 0x30; 
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:2]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}
//
//- (void)setOffsetGain:(NSNumber *)og {
//	char offsetGain = [og charValue];
//	
//	char data[2];
//	data[0]=0x34;
//	data[1]=offsetGain + 0x30; 
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:2]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}
//
//- (void)setOffsetCorrection:(NSNumber *)oc {
//	char offsetCorrection = [oc intValue];
//	
//	char data[2];
//	data[0]=0x35;
//	data[1]=offsetCorrection + 0x30; 
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:2]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}
//
//- (void)setReset:(NSNumber *)r {
//	char reset = [r intValue];
//	
//	char data[2];
//	data[0]=0x38;
//	data[1]=reset + 0x30; 
//	
//	[accessLock lock];
//	[self performSelectorOnMainThread:@selector(writeData:)
//						   withObject:[NSData dataWithBytes:data 
//													 length:2]
//						waitUntilDone:YES];
//	[accessLock unlock];
//}
//
//- (NSNumber *)pollUntilImageReady:(NSNumber *)maxAttempts {
//	int i = 0;
//	
//	do {
//		usleep(500000);
//		++i;
//	} while(i<[maxAttempts intValue] && ![[self validImage] boolValue]);
//
//	return [self validImage];
//}
//
//- (NSNumber *)pollUntilCameraReady:(NSNumber *)maxAttempts {
//	int i = 0;
//	
//	do {
//		usleep(500000);
//		++i;
//	} while(i<[maxAttempts intValue] && ![[self isReset] boolValue]);
//	
//	return [self isReset];
//}
//
//
//
//- (NSNumber *)validImage {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:ValidImage];
//}
//
//- (NSNumber *)validOffset {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:ValidOffset];
//}
//
//- (NSNumber *)validPixmap {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:ValidPixmap];
//}
//
//- (NSNumber *)offsetCorr {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:OffsetCorr];
//}
//
//- (NSNumber *)pixelCorr {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:PixelCorr];
//}
//
//- (NSNumber *)imageScale {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithShort:ImageScale];
//}
//
//- (NSNumber *)offsetScale {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithShort:OffsetScale];
//}
//
//- (NSNumber *)isReset {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:RESET];
//}
//
//- (NSNumber *)bin {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:BIN];
//}
//
//- (NSNumber *)ndr {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithBool:NDR];
//}
//
//- (NSNumber *)integrationTime {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithLong:IntTime];
//}
//
//- (NSNumber *)timingMode {
//	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
//						   withObject:nil
//						waitUntilDone:YES];
//	return [NSNumber numberWithShort:TimingMode];
//}
//
//
//- (NSData *)rawImage {
////	NSString *rawImagePath = [volumePath stringByAppendingPathComponent:RAW_IMAGE_FILE];
////	return [[NSFileManager defaultManager] contentsAtPath:rawImagePath];
//	[self performSelectorOnMainThread:@selector(getRawImage:)
//						   withObject:nil
//						waitUntilDone:YES];
//	
//	return rawImage;
//}
//
//- (NSData *)rawOffset {
//	[self performSelectorOnMainThread:@selector(getOffsetImage:)
//						   withObject:nil
//						waitUntilDone:YES];
//	
//	return rawOffset;
//}

- (void)setIntegrationTime:(NSTimeInterval)time_s {
	long counterTime = time_s*1000000/512;
	
	if(counterTime >= 0xFFFF) {
		counterTime = 0xFFF0;
	}
	
	char data[3];
	data[0]=0x3B;
	data[1]=(counterTime & 0xFF00) >> 8;
	data[2]=counterTime & 0x00FF;
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:3]
						waitUntilDone:YES];
}

- (void)setTimingMode:(char)timingMode {
	char data[2];
	data[0]=0x3E;
	data[1]=timingMode; 
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:2]
						waitUntilDone:YES];
}

- (void)setImageGain:(char)imageGain {
	char data[2];
	data[0]=0x33;
	data[1]=imageGain + 0x30; 
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:2]
						waitUntilDone:YES];
}

- (void)setOffsetGain:(char)offsetGain {
	char data[2];
	data[0]=0x34;
	data[1]=offsetGain + 0x30; 
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:2]
						waitUntilDone:YES];
}

- (void)setOffsetCorrection:(int)offsetCorrection {
	char data[2];
	data[0]=0x35;
	data[1]=offsetCorrection + 0x30; 
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:2]
						waitUntilDone:YES];
}

- (void)setReset:(char)reset {
	
	char data[2];
	data[0]=0x38;
	data[1]=reset + 0x30; 
	
	[self performSelectorOnMainThread:@selector(writeData:)
						   withObject:[NSData dataWithBytes:data 
													 length:2]
						waitUntilDone:YES];
}

- (BOOL)pollUntilImageReady:(int)maxAttempts {
	int i = 0;
	
	do {
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		++i;
	} while(i<maxAttempts && ![self validImage]);
	
	return [self validImage];
}

- (BOOL)pollUntilCameraReady:(int)maxAttempts {
	int i = 0;
	
	do {
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		++i;
	} while(i<maxAttempts && ![self isReset]);
	
	return [self isReset];
}



- (BOOL)validImage {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return ValidImage;
}

- (BOOL)validOffset {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return ValidOffset;
}

- (BOOL)validPixmap {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return ValidPixmap;
}

- (BOOL)offsetCorr {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return OffsetCorr;
}

- (BOOL)pixelCorr {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return PixelCorr;
}

- (short)imageScale {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return ImageScale;
}

- (short)offsetScale {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return OffsetScale;
}

- (BOOL)isReset {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return RESET;
}

- (BOOL)bin {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return BIN;
}

- (BOOL)ndr {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return NDR;
}

- (NSTimeInterval)integrationTime {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return IntTime/1000000.;
}

- (short)timingMode {
	[self performSelectorOnMainThread:@selector(readSetupFileAndUpdateValues:)
						   withObject:nil
						waitUntilDone:YES];
	return TimingMode;
}


- (NSData *)rawImage {
//	NSString *rawImagePath = [volumePath stringByAppendingPathComponent:RAW_IMAGE_FILE];
//	return [[NSFileManager defaultManager] contentsAtPath:rawImagePath];
	[self performSelectorOnMainThread:@selector(getRawImage:)
						   withObject:nil
						waitUntilDone:YES];
	
	return raw_image;
}

- (NSData *)rawOffset {
	[self performSelectorOnMainThread:@selector(getOffsetImage:)
						   withObject:nil
						waitUntilDone:YES];
	
	return raw_offset;
}

- (void)connect:(id)arg	{
	NSTask *diskutil=[[NSTask alloc] init];
    NSPipe *pipe=[[NSPipe alloc] init];

	NS_DURING
		[diskutil setLaunchPath:@"/usr/sbin/diskutil"];
	NS_HANDLER
		NSLog(@"connect Exception here: [diskutil setLaunchPath:@\"/usr/sbin/diskutil\"];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil setArguments:[NSArray arrayWithObjects:@"mount",[self devicePath], nil]];
	NS_HANDLER
		NSLog(@"connect Exception here: [diskutil setArguments:[NSArray arrayWithObjects:@\"mount\",devicePath,nil]];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil setStandardOutput:pipe];
	NS_HANDLER
		NSLog(@"connect Exception here: [diskutil setStandardOutput:pipe];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil launch];
	NS_HANDLER
		NSLog(@"connect Exception here: [diskutil launch];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil waitUntilExit];
	NS_HANDLER
		NSLog(@"connect Exception here: [diskutil waitUntilExit];");
	NS_ENDHANDLER
	
	NS_DURING
		[self readSetupFileAndUpdateValues:nil];
	NS_HANDLER
		NSLog(@"connect Exception here: [self readSetupFileAndUpdateValues:nil];");
	NS_ENDHANDLER
	
	[pipe release];
	[diskutil release];
}

- (void)disconnect:(id)arg {
	NSTask *diskutil=[[NSTask alloc] init];
	NSPipe *pipe=[[NSPipe alloc] init];
	
	NS_DURING
		[diskutil setLaunchPath:@"/usr/sbin/diskutil"];
	NS_HANDLER
		NSLog(@"disconnect Exception here: [diskutil setLaunchPath:@\"/usr/sbin/diskutil\"];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil setArguments:[NSArray arrayWithObjects:@"unmount", @"force", [self devicePath], nil]];
	NS_HANDLER
		NSLog(@"disconnect Exception here: [diskutil setArguments:[NSArray arrayWithObjects:@\"unmount\", @\"force\", devicePath,nil]];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil setStandardOutput:pipe];
	NS_HANDLER
		NSLog(@"disconnect Exception here: [diskutil setStandardOutput:pipe];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil launch];
	NS_HANDLER
		NSLog(@"disconnect Exception here: [diskutil launch];");
	NS_ENDHANDLER
	
	NS_DURING
		[diskutil waitUntilExit];
	NS_HANDLER
		NSLog(@"disconnect Exception here: [diskutil waitUntilExit];");
	NS_ENDHANDLER

	[pipe release];
	[diskutil release];
}

/////////////////////////////////////////////////////////////////////////////////
// private methods 
/////////////////////////////////////////////////////////////////////////////////
// must be run on main thread
- (void)writeData:(NSData *)data {	
	NSString *setupFile = [[self volumePath] stringByAppendingPathComponent:SETUP_FILE];
	
    [[NSFileManager defaultManager] removeItemAtPath:setupFile
                                               error:nil];
	[data writeToFile:setupFile atomically:YES];
//	[[NSFileManager defaultManager] createFileAtPath:setupFile
//											contents:data
//										  attributes:nil];
	
//	[NSThread detachNewThreadSelector:@selector(updateDevice:) toTarget:self withObject:self];
	[self updateDevice:self];
}

// must be run on main thread
- (void)getRawImage:(id)arg {
	NSString *rawImagePath = [[self volumePath] stringByAppendingPathComponent:RAW_IMAGE_FILE];
	NSData *newRawImage = [NSData dataWithContentsOfFile:rawImagePath];

	if(![newRawImage isEqualToData:raw_image]) {
		[raw_image release];
		raw_image = [newRawImage copy];	
	}
}

// must be run on main thread
- (void)getRawOffset:(id)arg {
	NSString *rawOffsetPath = [[self volumePath] stringByAppendingPathComponent:RAW_OFFSET_FILE];
	NSData *newRawOffset = [NSData dataWithContentsOfFile:rawOffsetPath];
	
	if(![newRawOffset isEqualToData:raw_offset]) {
		[raw_offset release];
		raw_offset = [newRawOffset copy];	
	}
}

//- (void)updateDevice:(id)arg {
//	usleep(500000);
//	[self performSelectorOnMainThread:@selector(disconnect:)
//						   withObject:nil
//						waitUntilDone:YES];
//						
//	usleep(200000);
//	
//	[self performSelectorOnMainThread:@selector(connect:)
//						   withObject:nil
//						waitUntilDone:YES];
//	usleep(500000);
//	
//}
- (void)updateDevice:(id)arg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	[self disconnect:nil];
//	[self performSelectorOnMainThread:@selector(disconnect:)
//						   withObject:nil
//						waitUntilDone:YES];
	
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	
	[self connect:nil];
//	[self performSelectorOnMainThread:@selector(connect:)
//						   withObject:nil
//						waitUntilDone:YES];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];	   
	[pool release];
}

// must happen on main thread
- (void)readSetupFileAndUpdateValues:(id)arg {
	NSString *file = [NSString stringWithContentsOfFile:[[self volumePath] stringByAppendingPathComponent:SETUP_FILE]
											   encoding:NSASCIIStringEncoding
												  error:nil];
	
	if([file length] < 232) {
		NSLog(@"Device %@ has not been reset properly", [self serialNumber]);
	}
	
	if(![[file substringWithRange:NSMakeRange(11,4)] isEqualToString:serial_number]) {
		[serial_number release];
		
		serial_number = [[file substringWithRange:NSMakeRange(11,4)] copy];
	}

	ValidImage = [[file substringWithRange:NSMakeRange(33,1)] intValue] > 0;
	
	ValidOffset = [[file substringWithRange:NSMakeRange(51,1)] intValue] > 0;
	
	ValidPixmap = [[file substringWithRange:NSMakeRange(69,1)] intValue] > 0;
	
	OffsetCorr = [[file substringWithRange:NSMakeRange(87,1)] intValue];
	
	PixelCorr = [[file substringWithRange:NSMakeRange(105,1)] intValue];
	
	ImageScale = [[file substringWithRange:NSMakeRange(123,1)] intValue];
	
	OffsetScale = [[file substringWithRange:NSMakeRange(141,1)] intValue];
	
	RESET = [[file substringWithRange:NSMakeRange(159,1)] intValue] > 0;
	
	NDR = [[file substringWithRange:NSMakeRange(177,1)] intValue] > 0;
	
	TimingMode = [[file substringWithRange:NSMakeRange(231,1)] intValue];
	
	NSScanner *scanner = [NSScanner scannerWithString:[file substringWithRange:NSMakeRange(208,5)]];
	unsigned int hexVal;
	
	[scanner scanHexInt:&hexVal];
	IntTime = hexVal*512;
}

- (NSString *)discoverDevicePath {
	struct statfs *buf = NULL;
	unsigned int count = getmntinfo(&buf, 0);
	
	for (int i=0; i<count; i++)
	{
		NSString *vol_name = [NSString stringWithCString:buf[i].f_mntonname encoding:NSASCIIStringEncoding];
		if([[self volumePath] isEqualToString:vol_name]) {
			return [NSString stringWithCString:buf[i].f_mntfromname encoding:NSASCIIStringEncoding];
		}
	}
	
	return nil;
}
//- (NSString *)discoverDevicePath {
//	NSTask *diskutil=[[NSTask alloc] init];
//    NSPipe *pipe=[[NSPipe alloc] init];
//    
//	[diskutil setLaunchPath:@"/usr/sbin/diskutil"];
//    [diskutil setArguments:[NSArray arrayWithObjects:@"list",volumePath,nil]];
//	
//	[diskutil setStandardOutput:pipe];
//    NSFileHandle *handle=[pipe fileHandleForReading];
//	
//    [diskutil launch];
//	[diskutil waitUntilExit];
//	
//	NSString *stdOut= [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
//	NSString *retval = [[NSString alloc] initWithString:[@"/dev/" stringByAppendingString:[stdOut substringWithRange:NSMakeRange(202,7)]]];
//
//	[stdOut release];
//	[pipe release];
//	[diskutil release];
//	
//	return retval;
//}


@end
