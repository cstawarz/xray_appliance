//
//  CocoaFFOR.h
//  XRayBox
//
//  Created by Ben Kennedy on 1/30/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define FFOR_ELEMENT_NAME @"name"
#define FFOR_ELEMENT_VISIBILITIES @"visibilities"
#define FFOR_ELEMENT_X @"X"
#define FFOR_ELEMENT_Y @"Y"
#define FFOR_ELEMENT_Z @"Z"


@interface CocoaFFOR : NSObject {
	NSString *name;
	NSString *nfs_name;
	NSArray *elements;
}

- (id) initWithFiducialFrameOfReferencePath:(NSString *)ffor_path
			   andNamedFiducialSetDirectory:(NSString *)nfs_directory;
+ (id)fforWithFiducialFrameOfReferencePath:(NSString *)ffor_path 
			  andNamedFiducialSetDirectory:(NSString *)nfs_directory;

- (NSString *)name;
- (NSString *)nfsName;
- (NSString *)abbreviatedName;
- (NSArray *)elements;
//@property (readonly) NSString *name, *nfsName, *abbreviatedName;
//@property (readonly) NSArray *elements;
@end
