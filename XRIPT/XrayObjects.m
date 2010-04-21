//
//  FiducialArray.m
//  XRayBox
//
//  Created by bkennedy on 1/17/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayObjects.h"
#import "CocoaNFS.h"
#import "PlotableXrayObject.h"
#import "ColorManager.h"


@interface XrayObjects (PrivateMethods) 
- (NSMutableArray *)mutableSets;
- (NSMutableArray *)mutableCurrentXrayObjects;
@end

@implementation XrayObjects


- (id)init {
	self = [super init];
	if(self != nil) {
		xray_object_sets = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[current_object_indexes release];
	[xray_object_sets release];
	[super dealloc];
}

- (void)addNFS:(CocoaNFS *)new_nfs {
	NSMutableDictionary *new_set = [NSMutableDictionary dictionary];
	NSMutableArray *fiducials = [NSMutableArray array];
	
	NSEnumerator *fiducial_enumerator = [[new_nfs fiducials] objectEnumerator];
	Fiducial *f = nil;
	int fiducial_index = 0;	
	
	while(f = [fiducial_enumerator nextObject]) {
		Fiducial *new_fiducial = [f copy];
		[[new_fiducial plotableObject] setColor:[ColorManager colorForIndex:fiducial_index++]];
		[fiducials addObject:[new_fiducial autorelease]];
	}

	[new_set setObject:fiducials forKey:XRAY_OBJECTS];
	[new_set setObject:[new_nfs name] forKey:XRAY_OBJECT_SET_NAME];
	
	NSDictionary *nonmutable_new_set = [NSDictionary dictionaryWithDictionary:new_set];
	// make the dictionary non-mutable
	[xray_object_sets addObject:nonmutable_new_set];
	if([xray_object_sets count] == 1) {
		[self setCurrentSet:nonmutable_new_set];
		[self setCurrentIndexes:[NSIndexSet indexSetWithIndex:0]];
	}
}

- (void)useNewXrayObjects:(NSArray *)new_xray_elements {
	[[self mutableCurrentXrayObjects] removeAllObjects];
	
	NSEnumerator *xray_element_enumerator = [new_xray_elements objectEnumerator];
	XrayObject *xro = nil;
	
	while(xro = [xray_element_enumerator nextObject]) {
		[self addXrayObject:xro];
	}
}

- (void)addXrayObject:(XrayObject *)new_xro {
	[[self mutableCurrentXrayObjects] addObject:new_xro];
	[self setCurrentSet:[self currentSet]]; // do this to force an update
	[self setCurrentIndexes:[NSIndexSet indexSetWithIndex:[[self currentXrayObjects] count]-1]];
}

- (NSArray *)currentXrayObjects {
	return [current_set objectForKey:XRAY_OBJECTS];
}	

- (NSMutableArray *)mutableCurrentXrayObjects {
	return [current_set objectForKey:XRAY_OBJECTS];
}	

- (void)setCurrentSetName:(NSString *)new_set_name {
	NSEnumerator *set_enumerator = [xray_object_sets objectEnumerator];
	NSDictionary *set_to_check = nil;
	
	while(set_to_check = [set_enumerator nextObject]) {
		if([new_set_name isEqualToString:[set_to_check objectForKey:XRAY_OBJECT_SET_NAME]]) {
			[self setCurrentSet:set_to_check];
			[self setCurrentIndexes:[NSIndexSet indexSetWithIndex:0]];
		}
	}
}

- (NSString *)currentSetName {
	return [current_set objectForKey:XRAY_OBJECT_SET_NAME];
}

- (XrayObject *)currentObject {
	return [[self currentXrayObjects] objectAtIndex:[current_object_indexes firstIndex]];
}

- (NSIndexSet *)currentIndexes {return current_object_indexes;}
- (void)setCurrentIndexes:(NSIndexSet *)new_index_set {
	[current_object_indexes release];
	current_object_indexes = [new_index_set copy];
}

- (NSDictionary *)currentSet {return current_set;}
- (void)setCurrentSet:(NSDictionary *)new_current_set {current_set=new_current_set;}


- (NSArray *)sets {return xray_object_sets;}
- (NSMutableArray *)mutableSets {return xray_object_sets;}

//@synthesize currentIndexes=current_object_indexes, currentSet=current_set, sets=xray_object_sets, mutableSets=xray_object_sets;

@end
