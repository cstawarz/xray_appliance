//
//  FFORManager.h
//  XRIPT
//
//  Created by bkennedy on 3/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaFFOR.h"


@interface FFORManager : NSObject {
	NSArray *possible_ffors;

	NSMutableArray *all_ffors;
	NSArray *current_xray_object_names;
}

- (NSArray *)possibleFFORs;
- (void)setPossibleFFORs:(NSArray *)new_possible_ffors;

- (NSArray *)currentXrayObjectNames;
- (void)setCurrentXrayObjectNames:(NSArray *)new_current_xray_object_names;


//@property (readwrite, retain) NSArray *possibleFFORs;
//@property (readwrite, retain) NSArray *currentXrayObjectNames;

- (void)addFFORToLibrary:(CocoaFFOR *)ffor;
- (void)setCurrentFFOR:(CocoaFFOR *)new_current_ffor;

@end
