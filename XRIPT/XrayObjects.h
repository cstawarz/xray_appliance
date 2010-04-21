//
//  XrayObjects.h
//  XRayBox
//
//  Created by bkennedy on 1/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaNFS.h"
#import "Fiducial.h"

#define XRAY_OBJECTS @"xrayObjects"
#define XRAY_OBJECT_SET_NAME @"name"

@interface XrayObjects : NSObject
{
	NSMutableArray *xray_object_sets;
	NSDictionary *current_set;
	NSIndexSet *current_object_indexes;
}

- (NSIndexSet *)currentIndexes;
- (void)setCurrentIndexes:(NSIndexSet *)new_index_set;

- (XrayObject *)currentObject;

- (NSDictionary *)currentSet;
- (void)setCurrentSet:(NSDictionary *)new_current_set;

- (NSString *)currentSetName;
- (void)setCurrentSetName:(NSString *)new_current_set_name;

- (NSArray *)sets;

- (NSArray *)currentXrayObjects;


//@property (readwrite, copy) NSIndexSet *currentIndexes;
//@property (readonly) XrayObject *currentObject;
//@property (readwrite, assign) NSDictionary *currentSet;
//@property (readwrite, assign) NSString *currentSetName;
//@property (readonly) NSArray *sets, *currentXrayObjects;
//// private
//@property (readonly) NSMutableArray *mutableSets, *mutableCurrentXrayObjects;

- (void)addNFS:(CocoaNFS *)new_nfs;
- (void)useNewXrayObjects:(NSArray *)new_xray_elements;
- (void)addXrayObject:(XrayObject *)new_xro;

@end