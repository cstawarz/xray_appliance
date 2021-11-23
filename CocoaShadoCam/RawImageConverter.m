//
//  RawImageConverter.m
//  CocoaShadoCam
//
//  Created by Ben Kennedy on 10/26/07.
//  Copyright 2007 MIT. All rights reserved.
//

#import "RawImageConverter.h"

@interface RawImageConverter(PrivateMethods)
+ (unsigned long)indexFromX:(long)x andY:(long)y;
+ (NSArray *)badPixels_0187;
+ (NSArray *)badColumns_0187;
+ (NSArray *)badPixels_0299;
+ (NSArray *)badColumns_0299;
+ (void)fixBadPixels:(NSArray *)badPixels 
				  at:(unsigned short *)pixel_data;
+ (void)fixBadColumns:(NSArray *)badColumns 
				   at:(unsigned short *)pixel_data;
+ (unsigned int)correctForEndianess:(unsigned int)old_pixel;
@end

#define SCALE_FACTOR_16BIT (0xFFFF/4095)

@implementation RawImageConverter

+ (NSData *)correctRawImage:(NSData *)raw_data
				 onDetector:(NSString *)serial_number {
	
	NSData *corrected_data = [[NSData alloc] initWithData:raw_data];
	
	unsigned short *pixel_data = (unsigned short *)[corrected_data bytes];
	
	if([serial_number isEqualToString:@"0187"]) {
		[self fixBadPixels:[self badPixels_0187] at:pixel_data];
		
		[self fixBadColumns:[self badColumns_0187] at:pixel_data];
		
		// next fix bad row segments (hard coded for now)
		const int min_column = 1;
		const int max_column = 64;
		const int row_above = 553;
		const int row_below = 558;
		
		for(int j = min_column; j <= max_column; ++j) {
			// find the pixel above the bad row
			const unsigned long aboveIndex = [self indexFromX:j andY:row_above];
			const unsigned long belowIndex = [self indexFromX:j andY:row_below];
			
			unsigned short *above_raw_pixel = pixel_data+aboveIndex;
			
			unsigned int abovePixel = [self correctForEndianess:*above_raw_pixel];
			
			// scale it to 16 bit
			abovePixel *= SCALE_FACTOR_16BIT;
			abovePixel = abovePixel > 0xFFFF ? 0xFFFF : abovePixel;
			
			// find the pixel below the bad row
			unsigned short *below_raw_pixel = pixel_data+belowIndex;

			unsigned int belowPixel = [self correctForEndianess:*below_raw_pixel];
			
			// scale it to 16 bit
			belowPixel *= SCALE_FACTOR_16BIT;
			belowPixel = belowPixel > 0xFFFF ? 0xFFFF : belowPixel;
			
			for(int i = row_above+1; i < row_below; ++i) {
				unsigned short newPixelValue = (belowPixel+abovePixel)/2;
				unsigned short newScaledPixelValue = newPixelValue/SCALE_FACTOR_16BIT;

				unsigned short newRawPixelValue = [self correctForEndianess:newScaledPixelValue];
				
				int arrayIndex = [self indexFromX:j andY:i];
				unsigned short *rawIndexToReplace = pixel_data+arrayIndex;
				*rawIndexToReplace = newRawPixelValue;
			}
		}
		
	} else if ([serial_number isEqualToString:@"0299"]) {
		[self fixBadPixels:[self badPixels_0299] at:pixel_data];
		[self fixBadColumns:[self badColumns_0299] at:pixel_data];
		

		// next fix bad column segments (hard coded for now)
		const int minRow = 1;
		const int maxRow = 229;
		const int badCol = 125;
		const int afterCol = badCol + 1;
		const int beforeCol = badCol - 1;
		
		for(int j = minRow; j <= maxRow; ++j) {
			// find the pixel after the bad column
			const unsigned long afterIndex = [self indexFromX:afterCol andY:j];
			const unsigned long beforeIndex = [self indexFromX:beforeCol andY:j];
			
			unsigned short *after_raw_pixel = pixel_data+afterIndex;

			unsigned int afterPixel = [self correctForEndianess:*after_raw_pixel];
			// scale it to 16 bit
			afterPixel *= SCALE_FACTOR_16BIT;
			afterPixel = afterPixel > 0xFFFF ? 0xFFFF : afterPixel;
			
			// find the pixel before the bad column
			unsigned short *before_raw_pixel = pixel_data+beforeIndex;

			unsigned int beforePixel = [self correctForEndianess:*before_raw_pixel];
			
			// scale it to 16 bit
			beforePixel *= SCALE_FACTOR_16BIT;
			beforePixel = beforePixel > 0xFFFF ? 0xFFFF : beforePixel;
			
			unsigned short newPixelValue = (beforePixel+afterPixel)/2;
			unsigned short newScaledPixelValue = newPixelValue/SCALE_FACTOR_16BIT;

			unsigned short newRawPixelValue = [self correctForEndianess:newScaledPixelValue];

			int arrayIndex = [self indexFromX:badCol andY:j];
			unsigned short *rawIndexToReplace = pixel_data+arrayIndex;
			*rawIndexToReplace = newRawPixelValue;
		}
		
	} else {
		// raise exception
	}
	
	// now add two columns to the center and remove the first and last column
	for(int j = 1; j <= 1000; ++j) {
		// shift all pixels left of 512 left one slot and all pixels right of 513 right one slot
		for(int i = 1; i < 512; ++i) {
			unsigned short *raw_pixel_to_replace = pixel_data+[self indexFromX:i andY:j];
			unsigned short *raw_pixel_replacing = pixel_data+[self indexFromX:i+1 andY:j];
			*raw_pixel_to_replace = *raw_pixel_replacing;
		}
		
		for(int i = 1024; i > 513; --i) {
			unsigned short *raw_pixel_to_replace = pixel_data+[self indexFromX:i andY:j];
			unsigned short *raw_pixel_replacing = pixel_data+[self indexFromX:i-1 andY:j];
			*raw_pixel_to_replace = *raw_pixel_replacing;
		}
		
		const unsigned long afterIndex = [self indexFromX:511 andY:j];
		const unsigned long beforeIndex = [self indexFromX:514 andY:j];
		
		unsigned short *after_raw_pixel = pixel_data+afterIndex;

		unsigned int afterPixel = [self correctForEndianess:*after_raw_pixel];
		
		// scale it to 16 bit
		afterPixel *= SCALE_FACTOR_16BIT;
		afterPixel = afterPixel > 0xFFFF ? 0xFFFF : afterPixel;
		
		// find the pixel before the bad column
		unsigned short *before_raw_pixel = pixel_data+beforeIndex;

		unsigned int beforePixel = [self correctForEndianess:*before_raw_pixel];
		// scale it to 16 bit
		beforePixel *= SCALE_FACTOR_16BIT;
		beforePixel = beforePixel > 0xFFFF ? 0xFFFF : beforePixel;
		
		unsigned short newPixelValue = (beforePixel+afterPixel)/2;
		unsigned short newScaledPixelValue = newPixelValue/SCALE_FACTOR_16BIT;

		unsigned short newRawPixelValue = [self correctForEndianess:newScaledPixelValue];
		
		unsigned short *rawIndexToReplace = pixel_data+[self indexFromX:512 andY:j];
		*rawIndexToReplace = newRawPixelValue;
		rawIndexToReplace = pixel_data+[self indexFromX:513 andY:j];
		*rawIndexToReplace = newRawPixelValue;
	}
	
	
    return corrected_data;
}

+ (NSData *)calibrateRawImage:(NSData *)raw_data 
				   onDetector:(NSString *)serial_number {	


	NSData *new_data = [[NSData alloc] initWithData:raw_data];
	unsigned short *pixel_data = (unsigned short *)[new_data bytes];

	NSArray *frameworks = [NSBundle allFrameworks];
	NSEnumerator *frameworks_enumerator = [frameworks objectEnumerator];
	id framework;
	
	while(framework = [frameworks_enumerator nextObject]) {
		if([[framework bundleIdentifier] isEqualToString:@"edu.mit.CocoaShadoCam"]) {
			break;
		}
	}
	
	if(framework == nil) {
		// throw exception
	}	
	
	NSString *offset_data_filename = @"offset";
	offset_data_filename = [[offset_data_filename stringByAppendingString:serial_number] stringByAppendingPathExtension:@"raw"];
	NSData *offset_data = [NSData dataWithContentsOfFile:[[framework resourcePath] stringByAppendingPathComponent:offset_data_filename]];
	unsigned short *offset_pixel_data = (unsigned short *)[offset_data bytes];
	
	
	NSString *gain_data_filename = @"gain";
	gain_data_filename = [[gain_data_filename stringByAppendingString:serial_number] stringByAppendingPathExtension:@"raw"];
	NSData *gain_data = [NSData dataWithContentsOfFile:[[framework resourcePath] stringByAppendingPathComponent:gain_data_filename]];
	unsigned short *gain_pixel_data = (unsigned short *)[gain_data bytes];	
	
	for (int x=0; x<1024; ++x) {
		for (int y=0; y<1000; ++y) {			
			// get the image pixel and swap the bytes
			unsigned short *raw_pixel = pixel_data+((y*1024)+x);

			unsigned int pixel = [self correctForEndianess:*raw_pixel];
			
			// get the offset pixel and swap the bytes
			unsigned short *offset_pixel = offset_pixel_data+((y*1024)+x);

			unsigned int corrected_offset_pixel = [self correctForEndianess:*offset_pixel];
			
			// get the gain pixel and swap the bytes
			unsigned short *gain_pixel = gain_pixel_data+((y*1024)+x);

			unsigned int corrected_gain_pixel = [self correctForEndianess:*gain_pixel];
			
			pixel = corrected_offset_pixel > pixel ? 0 : pixel-corrected_offset_pixel;
			
						
			// modify by the gain
			float gain_factor = (float)corrected_gain_pixel/(float)4095;
			pixel = gain_factor > 0 ? pixel/gain_factor : 4095;
						
			*raw_pixel = [self correctForEndianess:pixel];
		}
	}
		
    return new_data;
}

+ (NSBitmapImageRep *)convertRawToImage:(NSData *)raw_data
							 withMaxLUT:(unsigned short)max_LUT
							 withMinLUT:(unsigned short)min_LUT
						andSerialNumber:(NSString *)serial_number
						usingCorrection:(BOOL)should_correct_image
					andUsingCalibration:(BOOL)should_calibrate_image{
	
	NSData *new_data = raw_data;
	
	if(should_calibrate_image) {
		new_data = [self calibrateRawImage:new_data
							   onDetector:serial_number];
	}
		
	if(should_correct_image) {
		new_data = [self correctRawImage:new_data
							 onDetector:serial_number];
	}
	
	unsigned short *pixel_data = (unsigned short *)[new_data bytes];
	
	
	NSBitmapImageRep *raw_bitmap_rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
																	  pixelsWide:1024
																	  pixelsHigh:1000
																   bitsPerSample:16
																 samplesPerPixel:1
																		hasAlpha:NO
																		isPlanar:NO
																  colorSpaceName:NSDeviceWhiteColorSpace
																	 bytesPerRow:2048
																	bitsPerPixel:0];	
	
	float scaleFactor = max_LUT > min_LUT ? ((float)0xFFFF)/(max_LUT - min_LUT) : 0;
	
	for (int x=0; x<1024; ++x) {
		for (int y=0; y<1000; ++y) {			
			// get the image pixel and swap the bytes
			unsigned short *raw_pixel = pixel_data+((y*1024)+x);

			unsigned int pixel_ = [self correctForEndianess:*raw_pixel];
				
			// scale it to 16 bit
			pixel_ *= SCALE_FACTOR_16BIT;
			
			
			NSUInteger pixel = min_LUT > pixel_ ? 0 : pixel_ - min_LUT;
			pixel *= scaleFactor;
			pixel = pixel > 0xFFFF ? 0xFFFF : pixel;
			
			// if need to rotate and reflect
			//[d_raw setPixel:&pixel atX:x y:(1000-y)-1];
			
			// if just need to rotate
			[raw_bitmap_rep setPixel:&pixel atX:(1024-x)-1 y:(1000-y)-1];
		}
	}
	
	
    return raw_bitmap_rep;
}

// private methods

+ (unsigned long)indexFromX:(long)x andY:(long)y {
	return ((y-1)*1024)+(x-1);
}

+ (NSArray *)badPixels_0187 {
	NSMutableArray *badPixels = [[NSMutableArray alloc] initWithCapacity:34];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:47], [NSNumber numberWithInt:322], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:94], [NSNumber numberWithInt:564], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:158], [NSNumber numberWithInt:803], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:186], [NSNumber numberWithInt:964], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:200], [NSNumber numberWithInt:926], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:205], [NSNumber numberWithInt:614], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:206], [NSNumber numberWithInt:614], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:261], [NSNumber numberWithInt:767], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:270], [NSNumber numberWithInt:106], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:281], [NSNumber numberWithInt:1017], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:282], [NSNumber numberWithInt:1016], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:282], [NSNumber numberWithInt:1017], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:283], [NSNumber numberWithInt:1015], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:283], [NSNumber numberWithInt:1016], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:284], [NSNumber numberWithInt:1014], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:284], [NSNumber numberWithInt:1015], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:313], [NSNumber numberWithInt:882], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:313], [NSNumber numberWithInt:883], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:352], [NSNumber numberWithInt:724], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:352], [NSNumber numberWithInt:725], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:353], [NSNumber numberWithInt:241], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:412], [NSNumber numberWithInt:796], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:412], [NSNumber numberWithInt:797], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:438], [NSNumber numberWithInt:830], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:449], [NSNumber numberWithInt:980], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:522], [NSNumber numberWithInt:1006], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:522], [NSNumber numberWithInt:1007], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:523], [NSNumber numberWithInt:1007], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:608], [NSNumber numberWithInt:627], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:608], [NSNumber numberWithInt:628], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:644], [NSNumber numberWithInt:85], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:669], [NSNumber numberWithInt:224], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:721], [NSNumber numberWithInt:466], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:899], [NSNumber numberWithInt:810], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	
    return badPixels;
}

+ (NSArray *)badPixels_0299 {
	NSMutableArray *badPixels = [[NSMutableArray alloc] initWithCapacity:10];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:346], [NSNumber numberWithInt:30], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:347], [NSNumber numberWithInt:30], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:347], [NSNumber numberWithInt:31], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:893], [NSNumber numberWithInt:140], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:951], [NSNumber numberWithInt:215], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:952], [NSNumber numberWithInt:215], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:709], [NSNumber numberWithInt:336], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:683], [NSNumber numberWithInt:518], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:809], [NSNumber numberWithInt:761], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];
	[badPixels addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:810], [NSNumber numberWithInt:761], nil]
													 forKeys:[NSArray arrayWithObjects:@"Y", @"X", nil]]];	
	
    return badPixels;
}

+ (NSArray *)badColumns_0187 {
	NSMutableArray *badColumns = [[NSMutableArray alloc] initWithCapacity:2];
	
	[badColumns addObject:[NSNumber numberWithInt:257]];
	[badColumns addObject:[NSNumber numberWithInt:769]];
	
    return badColumns;
}

+ (NSArray *)badColumns_0299 {
	return [self badColumns_0187];
}


+ (void)fixBadColumns:(NSArray *)badColumns 
				   at:(unsigned short *)pixel_data {
	
	NSEnumerator *bcEnumerator = [badColumns objectEnumerator];
	NSNumber *badColumn;
	
	while((badColumn = [bcEnumerator nextObject])) {
		const int minRow = 1;
		const int maxRow = 1000;
		const int beforeCol = [badColumn intValue]-1;
		const int afterCol = [badColumn intValue]+1;			
		
		for(int j = minRow; j <= maxRow; ++j) {
			const unsigned long beforeIndex = [self indexFromX:beforeCol andY:j];
			const unsigned long afterIndex = [self indexFromX:afterCol andY:j];
			
			// get the value of the previous pixel
			unsigned short *before_raw_pixel = pixel_data+beforeIndex;

			unsigned int beforePixel = [self correctForEndianess:*before_raw_pixel];
			
			// scale it to 16 bit
			beforePixel *= SCALE_FACTOR_16BIT;
			beforePixel = beforePixel > 0xFFFF ? 0xFFFF : beforePixel;
			
			// find the pixel below the bad row
			unsigned short *after_raw_pixel = pixel_data+afterIndex;

			unsigned int afterPixel = [self correctForEndianess:*after_raw_pixel];
			
			// scale it to 16 bit
			afterPixel *= SCALE_FACTOR_16BIT;
			afterPixel = afterPixel > 0xFFFF ? 0xFFFF : afterPixel;
			
			unsigned short newPixelValue = (beforePixel+afterPixel)/2;
			unsigned short newScaledPixelValue = newPixelValue/SCALE_FACTOR_16BIT;

			unsigned short newRawPixelValue = [self correctForEndianess:newScaledPixelValue];

			int arrayIndex = [self indexFromX:[badColumn intValue] andY:j];
			unsigned short *rawIndexToReplace = pixel_data+arrayIndex;
			*rawIndexToReplace = newRawPixelValue;
		}
	}
}

+ (void)fixBadPixels:(NSArray *)badPixels 
				  at:(unsigned short *)pixel_data {
	// first fix bad pixels
	NSEnumerator *bpEnumerator = [badPixels objectEnumerator];
	NSDictionary *badPair;
	
	while((badPair = [bpEnumerator nextObject])) {
		unsigned int neighbors = 0;
		unsigned long long totalNeighborValue = 0;
		for(int i=-1; i<=1; ++i) {
			for(int j=-1; j<=1; ++j) {
				
				const long x = [[badPair objectForKey:@"X"] intValue] + i;
				const long y = [[badPair objectForKey:@"Y"] intValue] + j;
				
				if(x >= 0 && x < 1024 && y >= 0 && y < 1000) {
					const unsigned long index = [self indexFromX:x andY:y];
					
					// get the  pixel and swap the bytes
					unsigned short *raw_pixel = pixel_data+index;

					unsigned int pixel = [self correctForEndianess:*raw_pixel];

					// scale it to 16 bit
					pixel *= SCALE_FACTOR_16BIT;
					pixel = pixel > 0xFFFF ? 0xFFFF : pixel;
					totalNeighborValue += pixel;						
					
					++neighbors;
				}
			}
		}
		
		if(neighbors > 0) {
			unsigned short newPixelValue = totalNeighborValue/neighbors;
			unsigned short newScaledPixelValue = newPixelValue/SCALE_FACTOR_16BIT;

			unsigned short newRawPixelValue = [self correctForEndianess:newScaledPixelValue];


			unsigned short *rawIndexToReplace = pixel_data+([self indexFromX:[[badPair objectForKey:@"X"] intValue]
																	   andY:[[badPair objectForKey:@"Y"] intValue]]);
			*rawIndexToReplace = newRawPixelValue;
		}
		
	}	
}

+ (unsigned int)correctForEndianess:(unsigned int)oldPixel {
#ifndef __ppc__
	unsigned short newPixelValue = (oldPixel & 0x00FF) << 8;
	return newPixelValue | ((oldPixel & 0xFF00) >> 8);
#else
	return oldPixel;
#endif	
}

@end
