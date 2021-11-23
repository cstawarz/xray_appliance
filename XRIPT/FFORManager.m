//
//  FFORManager.m
//  XRIPT
//
//  Created by bkennedy on 3/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "FFORManager.h"

@implementation FFORManager


- (id)init {
	self = [super init];
	if(self != nil) {
		all_ffors = [[NSMutableArray alloc] init];
	}
	return self;
}	

- (void)addFFORToLibrary:(CocoaFFOR *)ffor {
	[all_ffors addObject:ffor];
}


- (NSArray *)currentXrayObjectNames {return current_xray_object_names;}
- (void)setCurrentXrayObjectNames:(NSArray *)new_current_xray_object_names {
	current_xray_object_names = new_current_xray_object_names;
	
	NSMutableArray *temp_current_ffors = [NSMutableArray array];
	
	NSEnumerator *ffor_enumerator = [all_ffors objectEnumerator];
	CocoaFFOR *ffor = nil;
	
	// this is pretty shitty...but it works and the sets will likely never be large enough to cause a slow down
	while(ffor = [ffor_enumerator nextObject]) {
		int number_of_matches = 0;
		NSArray *fiducials_in_ffor = [ffor elements];
		
		NSEnumerator *xray_object_name_enumerator = [[self currentXrayObjectNames] objectEnumerator];
		NSString *xray_object_name = nil;
		
		while(xray_object_name = [xray_object_name_enumerator nextObject]) {
			NSEnumerator *ffor_fiducial_enumertor = [fiducials_in_ffor objectEnumerator];
			NSDictionary *fiducial = nil;
			
			while(fiducial = [ffor_fiducial_enumertor nextObject]) {
				NSString *full_fiducial_name = [NSString stringWithFormat:@"%@.%@", [ffor nfsName], [fiducial objectForKey:@"name"]];
				if([full_fiducial_name isEqualToString:xray_object_name]) {
					number_of_matches++;
				}	
			}
		}
		if(number_of_matches >= 3) {
			[temp_current_ffors addObject:ffor];
		}
	}
	
	[self setPossibleFFORs:temp_current_ffors];
}

- (void)setCurrentFFOR:(CocoaFFOR *)new_current_ffor {
	NSMutableArray *fiducial_names = [NSMutableArray array];
	
	NSEnumerator *new_ffor_elements_enumerator = [[new_current_ffor elements] objectEnumerator];
	NSDictionary *fiducial = nil;
	
	while(fiducial = [new_ffor_elements_enumerator nextObject]) {
		NSString *full_fiducial_name = [NSString stringWithFormat:@"%@.%@", [new_current_ffor nfsName], [fiducial objectForKey:@"name"]];
		[fiducial_names addObject:full_fiducial_name];
	}
	
	[self setCurrentXrayObjectNames:fiducial_names];
}

- (NSArray *)possibleFFORs {return possible_ffors;}
- (void)setPossibleFFORs:(NSArray *)new_possible_ffors {
	possible_ffors = new_possible_ffors;
}

//@synthesize possibleFFORs=possible_ffors, currentXrayObjectNames=current_xray_object_names;

@end
