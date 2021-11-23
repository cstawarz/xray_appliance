//
//  CocoaNFS.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/18/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CocoaNFS.h"
#import "Fiducial.h"


@implementation CocoaNFS

- (id) initWithNamedFiducialSetPath:(NSString *)nfs_path {
	self = [super init];
	if (self != nil) {
		NSXMLDocument *info_xml = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:nfs_path]
															   options:0
																 error:nil];
		
		
		{
			NSArray *name_nodes = [info_xml nodesForXPath:@"./object/name"
													error:nil];
			
			if([name_nodes count] != 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./object/name",
				 nfs_path];			
			}
			name = [[NSString alloc] initWithString:[[name_nodes objectAtIndex:0] stringValue]];
		}
		{
			NSArray *notes_nodes = [info_xml nodesForXPath:@"./object/notes"
													 error:nil];
			
			if([notes_nodes count] != 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./object/notes",
				 nfs_path];			
			}
			notes = [[NSString alloc] initWithString:[[notes_nodes objectAtIndex:0] stringValue]];
		}
		{
			NSArray *fiducial_nodes = [info_xml nodesForXPath:@"./object/fiducials/fiducial"
														error:nil];
			
			if([fiducial_nodes count] < 1) {
				[NSException raise:NSInternalInconsistencyException
							format:@"%@ fails xPath query: ./object/fiducials/fiducial",
				 nfs_path];			
			}
			
			NSXMLElement *fiducial_node;
			NSEnumerator *enumerator = [fiducial_nodes objectEnumerator];			
			NSMutableArray *temp_fiducials = [NSMutableArray array];
			
			while(fiducial_node = [enumerator nextObject]) {
				NSString *fiducial_name = [[fiducial_node attributeForName:@"name"] stringValue];
				NSString *fiducial_visibility = [[fiducial_node attributeForName:@"visibility"] stringValue];
				
				Fiducial *fiducial = [Fiducial fiducialWithName:fiducial_name 
												   andVisibility:fiducial_visibility];
				
				[temp_fiducials addObject:fiducial];
			}			
			
			fiducials = [[NSArray alloc] initWithArray:temp_fiducials];
		}
	}
	return self;
}

+ (id)nfsWithNamedFiducialSetPath:(NSString *)nfs_path {	
	return [[self alloc] initWithNamedFiducialSetPath:nfs_path];
}


- (NSString *)name {return name;}
- (void)setName:(NSString *)new_name {
	name = [new_name copy];
}

- (NSString *)notes{return notes;}
- (void)setNotes:(NSString *)new_notes {
	notes = [new_notes copy];
}

- (NSArray *)fiducials {return fiducials;}

//@synthesize notes=notes, name=name, fiducials=fiducials;


@end
