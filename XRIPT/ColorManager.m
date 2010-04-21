//
//  ColorArray.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/25/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "ColorManager.h"


@implementation ColorManager

+ (NSColor *)colorForIndex:(int)index {
	switch(index) {
		case 1:
			return [NSColor redColor];
			break;
		case 2:
			return [NSColor blueColor];
			break;
		case 3:
			return [NSColor cyanColor];
			break;
		case 4:
			return [NSColor greenColor];
			break;
		case 5:
			return [NSColor orangeColor];
			break;
		case 6:
			return [NSColor purpleColor];
			break;
		case 7:
			return [NSColor yellowColor];
			break;
		case 8:
			return [NSColor magentaColor];
			break;
		case 9:
			return [NSColor brownColor];
			break;
		case 10:
			return [NSColor colorWithCalibratedRed:0.4898
											 green:0.7060
											  blue:0.1419
											 alpha:1];
			break;
		case 11:
			return [NSColor colorWithCalibratedRed:0.4456
											 green:0.0318
											  blue:0.4218
											 alpha:1];
			break;
		case 12:
			return [NSColor colorWithCalibratedRed:0.6463
											 green:0.2769
											  blue:0.9157
											 alpha:1];
			break;
		case 13:
			return [NSColor colorWithCalibratedRed:0.7094
											 green:0.0462
											  blue:0.7922
											 alpha:1];
			break;
		case 14:
			return [NSColor colorWithCalibratedRed:0.7547
											 green:0.0971
											  blue:0.9595
											 alpha:1];
			break;
		case 15:
			return [NSColor colorWithCalibratedRed:0.2760
											 green:0.8235
											  blue:0.6557
											 alpha:1];
			break;
		case 16:
			return [NSColor colorWithCalibratedRed:0.6797
											 green:0.6948
											  blue:0.0357
											 alpha:1];
			break;
		case 17:
			return [NSColor colorWithCalibratedRed:0.6551
											 green:0.3171
											  blue:0.8491
											 alpha:1];
			break;
		case 18:
			return [NSColor colorWithCalibratedRed:0.1626
											 green:0.9502
											  blue:0.9340
											 alpha:1];
			break;
		case 19:
			return [NSColor colorWithCalibratedRed:0.1190
											 green:0.0344
											  blue:0.6787
											 alpha:1];
			break;
		case 20:
			return [NSColor colorWithCalibratedRed:0.4984
											 green:0.4387
											  blue:0.7577
											 alpha:1];
			break;
		case 21:
			return [NSColor colorWithCalibratedRed:0.9597
											 green:0.3816
											  blue:0.7431
											 alpha:1];
			break;
		case 22:
			return [NSColor colorWithCalibratedRed:0.3404
											 green:0.7655
											  blue:0.3922
											 alpha:1];
			break;
		case 23:
			return [NSColor colorWithCalibratedRed:0.5853
											 green:0.7952
											  blue:0.6555
											 alpha:1];
			break;
		case 24:
			return [NSColor colorWithCalibratedRed:0.2238
											 green:0.1869
											  blue:0.1712
											 alpha:1];
			break;
		case 25:
			return [NSColor colorWithCalibratedRed:0.2238
											 green:0.7869
											  blue:0.1242
											 alpha:1];
			break;			
		default:
			return [NSColor redColor];
			break;
	}
}

@end
