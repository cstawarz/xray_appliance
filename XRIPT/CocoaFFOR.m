//
//  CocoaFFOR.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/30/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CocoaFFOR.h"
#import "CocoaNFS.h"
#import "Fiducial.h"

@implementation CocoaFFOR

- (id) initWithFiducialFrameOfReferencePath:(NSString *)ffor_path
			   andNamedFiducialSetDirectory:(NSString *)nfs_directory {
	self = [super init];
	if (self != nil) {
		NSXMLDocument *info_xml = [[[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:ffor_path]
															   options:0
																 error:nil] autorelease];
		
		
		{
			NSArray *name_nodes = [info_xml nodesForXPath:@"./frame/name"
													error:nil];
			
			if([name_nodes count] != 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./frame/name",
				 @"XML file"];			
			}
			name = [[NSString alloc] initWithString:[[name_nodes objectAtIndex:0] stringValue]];
		}
		{
			NSArray *nfs_name_nodes = [info_xml nodesForXPath:@"./frame/object"
														error:nil];
			
			if([nfs_name_nodes count] != 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./frame/object",
				 @"XML file"];			
			}
			nfs_name = [[NSString alloc] initWithString:[[nfs_name_nodes objectAtIndex:0] stringValue]];
		}
		{
			NSString *nfs_path = [nfs_directory stringByAppendingPathComponent:[nfs_name stringByAppendingPathExtension:@"xml"]];
			
			CocoaNFS *nfs = [[CocoaNFS alloc] initWithNamedFiducialSetPath:nfs_path];
			NSArray *point_nodes = [info_xml nodesForXPath:@"./frame/points/point"
													 error:nil];

			if([point_nodes count] < 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./frame/points/point",
				 @"XML file"];			
			}
			
			NSMutableArray *temp_elements = [NSMutableArray array];
			
			NSEnumerator *point_enumerator = [point_nodes objectEnumerator];
			NSXMLElement *point = nil;
			
			while(point = [point_enumerator nextObject]) {
				NSString *fiducial_name = [[point attributeForName:@"name"] stringValue];
				if(fiducial_name == nil) {
					[NSException raise:NSInternalInconsistencyException 
								format:@"Point (./frame/points/point) in %@ doesn't have a name", ffor_path];
				}
				
				NSString *fiducial_visibility = @"";
				
				NSEnumerator *nfs_fiducial_enumerator = [[nfs fiducials] objectEnumerator];
				Fiducial *nfs_fiducial=nil;
				
				while(nfs_fiducial = [nfs_fiducial_enumerator nextObject]) {
					if([[nfs_fiducial name] isEqualToString:fiducial_name]) {
						fiducial_visibility = [nfs_fiducial visibility];
						break;
					}
				}
				
				float x = [[[point attributeForName:@"x"] stringValue] floatValue];
				float y = [[[point attributeForName:@"y"] stringValue] floatValue];
				float z = [[[point attributeForName:@"z"] stringValue] floatValue];
				NSMutableDictionary *point_3D = [NSMutableDictionary dictionary];
				
				[point_3D setObject:[NSNumber numberWithFloat:x]
							 forKey:FFOR_ELEMENT_X];
				[point_3D setObject:[NSNumber numberWithFloat:y]
							 forKey:FFOR_ELEMENT_Y];
				[point_3D setObject:[NSNumber numberWithFloat:z]
							 forKey:FFOR_ELEMENT_Z];
				[point_3D setObject:fiducial_visibility
							 forKey:FFOR_ELEMENT_VISIBILITIES];
				[point_3D setObject:fiducial_name
							 forKey:FFOR_ELEMENT_NAME];
				[temp_elements addObject:point_3D];

			}
			elements = [[NSArray alloc] initWithArray:temp_elements];
		}
	}
	return self;
}

+ (id)fforWithFiducialFrameOfReferencePath:(NSString *)ffor_path 
			  andNamedFiducialSetDirectory:(NSString *)nfs_directory {
	return [[[self alloc] initWithFiducialFrameOfReferencePath:ffor_path 
								  andNamedFiducialSetDirectory:nfs_directory] autorelease];
}

- (void) dealloc {
	[elements release];
	[name release];
	[nfs_name release];
	[super dealloc];
}

- (NSString *)name {return name;}
- (NSString *)nfsName {return nfs_name;}
- (NSArray *)elements {return elements;}

//@synthesize name=name, nfsName=nfs_name, elements=elements;

- (NSString *)abbreviatedName {
	return [[name componentsSeparatedByString:@"_"] lastObject];
}

@end
