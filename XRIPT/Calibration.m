//
//  Calibration.m
//  XRayBox
//
//  Created by Ben Kennedy on 2/12/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "Calibration.h"
#import "CocoaMxArray.h"
#import "mat.h"

@interface Calibration (PrivateMembers)
- (TransformableObject *)createSDP:(CocoaMxArray *)calibration_array withIndex:(int)index;
- (TransformableObject *)createTransformableObject:(CocoaMxArray *)transformable_object_array;
@end

@implementation Calibration

- (id)initWithFile:(NSString *)calibration_file {
	self = [super init];
	if (self != nil) {
		if([[[calibration_file lastPathComponent] pathExtension] isEqualToString:@"mat"]) {
			MATFile *calibration_mat_file = matOpen([calibration_file cStringUsingEncoding:NSASCIIStringEncoding], "r");
			
			mxArray *calibration = matGetVariable(calibration_mat_file, "calibrated_system_MATLAB");
			
			// Get the name
			mxArray *name_array = mxGetField(calibration, 0, "name");
			char *name_buf = (char *)calloc(mxGetNumberOfElements(name_array)+1, sizeof(char));
			mxGetString(name_array, name_buf, mxGetNumberOfElements(name_array)+1);
			
			name = [[NSString alloc] initWithCString:name_buf
											encoding:NSASCIIStringEncoding];		
			free(name_buf);
			
			// get the date
			mxArray *date_array = mxGetField(calibration, 0, "date");
			char *date_buf = (char *)calloc(mxGetNumberOfElements(date_array)+1, sizeof(char));
			mxGetString(date_array, date_buf, mxGetNumberOfElements(date_array)+1);
			
			NSString *temp_date = [NSString stringWithCString:date_buf
													 encoding:NSASCIIStringEncoding];		
			free(date_buf);
			
			NSString *YYYY = [temp_date substringWithRange:NSMakeRange(0,4)];
			NSString *MMonth = [temp_date substringWithRange:NSMakeRange(4,2)];
			NSString *DD = [temp_date substringWithRange:NSMakeRange(6,2)];
			NSString *HH = [temp_date substringWithRange:NSMakeRange(9,2)];
			NSString *MMinute = [temp_date substringWithRange:NSMakeRange(11,2)];
			NSString *SS = [temp_date substringWithRange:NSMakeRange(13,2)];
			NSString *HHMM = @"-0500";
			NSString *standard_time_string = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ %@",
				YYYY, MMonth, DD, HH, MMinute, SS, HHMM];
			date = [[NSDate alloc] initWithString:standard_time_string];
			
			NSMutableArray *temp_sdps = [NSMutableArray array];
			// create the source/detector pairs
			mxArray *temp_sdps_array = mxGetField(calibration, 0, "sdp");
			int number_of_sdps = mxGetNumberOfElements(temp_sdps_array);
			
			for(int i=0; i<number_of_sdps; ++i) {
				[temp_sdps addObject:[self createSDP:[CocoaMxArray arrayWithMxArray:calibration] withIndex:i]];
			}
			
			sdps = [[NSArray alloc] initWithArray:temp_sdps];
			
			mxArray *guess = mxGetField(calibration, 0, "guess");
			mxArray *rotation_spread = mxGetField(guess, 0, "rotationSpread");
			init_rotation_spread = mxGetScalar(rotation_spread);

			mxArray *detector_distances = mxGetField(guess, 0, "detectorDistances");
			mxArray *source_distances = mxGetField(guess, 0, "sourceDistances");

			NSMutableArray *temp_detector_distances = [NSMutableArray array];
			NSMutableArray *temp_source_distances = [NSMutableArray array];
			for(int i=0; i<number_of_sdps; ++i) {
				double *detector_distances_ptr = mxGetPr(detector_distances);
				[temp_detector_distances addObject:[NSNumber numberWithDouble:detector_distances_ptr[i]]];
				
				double *source_distances_ptr = mxGetPr(source_distances);
				[temp_source_distances addObject:[NSNumber numberWithDouble:source_distances_ptr[i]]];
			}
			
			init_detector_distances = [[NSArray alloc] initWithArray:temp_detector_distances];
			init_source_distances = [[NSArray alloc] initWithArray:temp_source_distances];
			
			
			mxDestroyArray(calibration);
			matClose(calibration_mat_file);
			
			calibration_mat_file_contents = [[NSData alloc] initWithContentsOfFile:calibration_file];
		}
		/* else if([[[calibration_file lastPathComponent] pathExtension] isEqualToString:@"xml"]) {
			NSURL *xml_location = [NSURL fileURLWithPath:calibration_file];
			
			NSXMLDocument *calibration_xml = [[NSXMLDocument alloc] initWithContentsOfURL:xml_location
																	   options:0
																		 error:nil];
			
			{
				NSArray *name_nodes = [calibration_xml nodesForXPath:@"./system_geometry/Name"
														error:nil];
				
				if([name_nodes count] != 1) {
					[NSException raise:NSInternalInconsistencyException
								format:@"%@ fails xPath query: ./system_geometry/Name",
						calibration_file];			
				}
				name = [[[name_nodes objectAtIndex:0] stringValue] copy];
			}
			{
				NSArray *date_nodes = [calibration_xml nodesForXPath:@"./system_geometry/Date"
														error:nil];
				
				if([date_nodes count] != 1) {
					[NSException raise:NSInternalInconsistencyException
								format:@"%@ fails xPath query: ./system_geometry/Date",
						calibration_file];			
				}

				NSArray *time_nodes = [calibration_xml nodesForXPath:@"./system_geometry/Time"
														error:nil];
				
				if([time_nodes count] != 1) {
					[NSException raise:NSInternalInconsistencyException
								format:@"%@ fails xPath query: ./system_geometry/Time",
						calibration_file];			
				}
				
				NSString *temp_date = [[date_nodes objectAtIndex:0] stringValue];
				NSString *temp_time = [[time_nodes objectAtIndex:0] stringValue];

				NSString *YYYY = [temp_date substringWithRange:NSMakeRange(0,4)];
				NSString *MMonth = [temp_date substringWithRange:NSMakeRange(5,2)];
				NSString *DD = [temp_date substringWithRange:NSMakeRange(8,2)];
				NSString *HH = [temp_time substringWithRange:NSMakeRange(0,2)];
				NSString *MMinute = [temp_time substringWithRange:NSMakeRange(3,2)];
				NSString *SS = [temp_time substringWithRange:NSMakeRange(6,2)];
				NSString *HHMM = @"-0500";
				NSString *standard_time_string = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ %@",
					YYYY, MMonth, DD, HH, MMinute, SS, HHMM];
				date = [[NSDate alloc] initWithString:standard_time_string];
			}
			{
				NSArray *sdp_nodes = [calibration_xml nodesForXPath:@"./system_geometry/SourceDetectorPairs"
																		  error:nil];

				NSEnumerator *sdp_node_enumerator = [sdp_nodes objectEnumerator];
				NSXMLNode *sdp_node = nil;
				
				NSMutableArray *temp_sdps = [NSMutableArray array];
				
				while(sdp_node = [sdp_node_enumerator nextObject]) {
					NSEnumerator *sdp_item_enumerator = [sdp_node children];
					NSXMLNode *sdp_item = nil;
					
					while(sdp_item = [sdp_item_enumerator nextObject]) {
						
					}
				}
			}
		}
		 */
	}
	return self;
}


+ (id)calibrationWithFile:(NSString *)calibration_mat_file {
	return [[[self alloc] initWithFile:calibration_mat_file] autorelease];
}

- (void) dealloc {
	[init_source_distances release];
	[init_detector_distances release];
	[sdps release];
	[date release];
	[name release];
	[super dealloc];
}

- (TransformableObject *)createSDP:(CocoaMxArray *)calibration_array
						 withIndex:(int) index {
	mxArray *calibration = [calibration_array array];
	
	mxArray *sdps_array = mxGetField(calibration, 0, "sdp");
	mxArray *sdp_array = mxGetCell(sdps_array, index);
	
	TransformableObject *current_sdp = [self createTransformableObject:[CocoaMxArray arrayWithMxArray:sdp_array]];
	mxArray *source_array = mxGetField(sdp_array, 0, "source");
	TransformableObject *source = [self createTransformableObject:[CocoaMxArray arrayWithMxArray:source_array]];
	
	mxArray *detector_array = mxGetField(sdp_array, 0, "detector");
	TransformableObject *detector = [self createTransformableObject:[CocoaMxArray arrayWithMxArray:detector_array]];
	
	return [SourceDetectorPair sdpWithTranslation:[current_sdp translation]
										 rotation:[current_sdp rotation]
										   source:source
									  andDetector:detector];
}

- (TransformableObject *)createTransformableObject:(CocoaMxArray *)transformable_object_array {
	mxArray *working_array = [transformable_object_array array];
	mxArray *translation_array = mxGetField(working_array, 0, "translation");
	mxArray *rotation_array = mxGetField(working_array, 0, "rotation");
	
	double *trans = mxGetPr(translation_array);
	double *rot = mxGetPr(rotation_array);
	
	return [TransformableObject objectWithTranslation:trans
										  andRotation:rot];
}

- (NSString *)name { return name; }
- (NSDate *)date { return date; }
- (NSArray *)sourceDetectorPairs { return sdps; }
- (float)initRotationSpread { return init_rotation_spread; }
- (NSArray *)initDetectorDistances { return init_detector_distances; }
- (NSArray *)initSourceDistances { return init_source_distances; }


- (void)write:(NSString *)directory {
	[calibration_mat_file_contents writeToFile:[directory stringByAppendingPathComponent:@"calibration.mat"] atomically:YES];
	
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"system_geometry"];
	
	{
		NSXMLElement *XML_name = [[[NSXMLElement alloc] initWithName:@"Name" 
														 stringValue:name] autorelease];
		[root addChild:XML_name];
	}
	
	{
		NSXMLElement *XML_date = [[[NSXMLElement alloc] initWithName:@"Date" 
														 stringValue:[date descriptionWithCalendarFormat:@"%Y-%m-%d"
																								timeZone:nil 
																								  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] autorelease];
		[root addChild:XML_date];
	}
	
	{
		NSXMLElement *XML_time = [[[NSXMLElement alloc] initWithName:@"Time" 
														 stringValue:[date descriptionWithCalendarFormat:@"%H:%M:%S"
																								timeZone:nil 
																								  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] autorelease];
		[root addChild:XML_time];
	}
	
	NSXMLElement *sdps_xml = [[[NSXMLElement alloc] initWithName:@"SourceDetectorPairs"] autorelease];
	NSEnumerator *sdp_enumerator = [sdps objectEnumerator];
	SourceDetectorPair *sdp = nil;
	while(sdp = [sdp_enumerator nextObject]) {
		NSXMLElement *sdp_xml = [[[NSXMLElement alloc] initWithName:@"SourceDetectorPair"] autorelease];
		
		// translation
		double *translation = [sdp translation];
		NSString *translation_string = [NSString stringWithFormat:@"%f %f %f", translation[0], translation[1], translation[2]]; 
		NSXMLElement *sdp_translation_xml = [[[NSXMLElement alloc] initWithName:@"Translation" 
																	stringValue:translation_string] autorelease];
		[sdp_xml addChild:sdp_translation_xml];
		
		// rotation
		double *rotation = [sdp rotation];
		NSString *rotation_string = [NSString stringWithFormat:@"%f %f %f", rotation[0], rotation[1], rotation[2]]; 
		NSXMLElement *sdp_rotation_xml = [[[NSXMLElement alloc] initWithName:@"Rotation" 
																 stringValue:rotation_string] autorelease];
		[sdp_xml addChild:sdp_rotation_xml];
		
		// source
		NSXMLElement *source_xml = [[[NSXMLElement alloc] initWithName:@"Source"] autorelease];
		TransformableObject *source = [sdp source];
		
		// source translation
		double *source_translation = [source translation];
		NSString *source_translation_string = [NSString stringWithFormat:@"%f %f %f", source_translation[0], source_translation[1], source_translation[2]]; 
		NSXMLElement *source_translation_xml = [[[NSXMLElement alloc] initWithName:@"Translation" 
																	   stringValue:source_translation_string] autorelease];
		[source_xml addChild:source_translation_xml];
		
		// source rotation
		double *source_rotation = [source rotation];
		NSString *source_rotation_string = [NSString stringWithFormat:@"%f %f %f", source_rotation[0], source_rotation[1], source_rotation[2]]; 
		NSXMLElement *source_rotation_xml = [[[NSXMLElement alloc] initWithName:@"Rotation" 
																	stringValue:source_rotation_string] autorelease];
		[source_xml addChild:source_rotation_xml];
		
		[sdp_xml addChild:source_xml];
		
		// detector
		NSXMLElement *detector_xml = [[[NSXMLElement alloc] initWithName:@"Detector"] autorelease];
		TransformableObject *detector = [sdp detector];
		
		// detector translation
		double *detector_translation = [detector translation];
		NSString *detector_translation_string = [NSString stringWithFormat:@"%f %f %f", detector_translation[0], detector_translation[1], detector_translation[2]]; 
		NSXMLElement *detector_translation_xml = [[[NSXMLElement alloc] initWithName:@"Translation" 
																		 stringValue:detector_translation_string] autorelease];
		[detector_xml addChild:detector_translation_xml];
		
		// detector rotation
		double *detector_rotation = [detector rotation];
		NSString *detector_rotation_string = [NSString stringWithFormat:@"%f %f %f", detector_rotation[0], detector_rotation[1], detector_rotation[2]]; 
		NSXMLElement *detector_rotation_xml = [[[NSXMLElement alloc] initWithName:@"Rotation" 
																	  stringValue:detector_rotation_string] autorelease];
		[detector_xml addChild:detector_rotation_xml];
		
		[sdp_xml addChild:detector_xml];
		
		
		[sdps_xml addChild:sdp_xml];
	}
	
	[root addChild:sdps_xml];
	
	NSXMLDocument *doco = [[[NSXMLDocument alloc] initWithRootElement:root] autorelease];
	
	[[doco XMLDataWithOptions:NSXMLNodePrettyPrint] writeToFile:[directory stringByAppendingPathComponent:@"calibration.xml"]
														options:0
														  error:nil];
}

@end
