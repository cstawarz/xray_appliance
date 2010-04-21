//
//  CocoaNFS.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CocoaNFS : NSObject {
	NSString *name;
	NSString *notes;
	NSArray *fiducials;
}

- (NSString *)name;
- (void)setName:(NSString *)new_name;

- (NSString *)notes;
- (void)setNotes:(NSString *)new_notes;

- (NSArray *)fiducials;

- (id)initWithNamedFiducialSetPath:(NSString *)nfs_path;
+ (id)nfsWithNamedFiducialSetPath:(NSString *)nfs_path;

@end
