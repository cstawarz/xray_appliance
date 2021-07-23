//
//  XrayBundleMATLABInterface.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/27/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayBundleMATLABInterface.h"
#import "XrayConstants.h"
#import "Electrode.h"
#import "Fiducial.h"
#import "GlobalMATLABEngine.h"
#import "CocoaMxArray.h"
#import "mat.h"
#import "engine.h"

@interface XrayBundleMATLABInterface (PrivateMethods)
+ (void)writeRHS:(NSArray *)xray_objects
		toBundle:(NSString *)bundle_path;
+ (CocoaMxArray *)raw2mat:(NSString *)bundle_path
			  forDetector:(Detector)detector;
@end

@implementation XrayBundleMATLABInterface

+ (void)write:(NSArray *)xray_objects
	 toBundle:(NSString *)bundle_path {
	
	mxArray *xray_objects_array = mxCreateCellMatrix(1, [xray_objects count]);	
	
	for(unsigned int i=0; i < [xray_objects count]; ++i) {
		XrayObject *xro = [xray_objects objectAtIndex:i];
		
		const char *object_elements [] = {"name", "center", "color", "type", "visibility"};
		const char **object_fieldnames = (const char **)calloc(sizeof(object_elements)/sizeof(*object_elements),
															   sizeof(const char *));
		//			const char **object_fieldnames = new const char *[sizeof(object_elements)/sizeof(*object_elements)];
		
		for(int j=0; j<sizeof(object_elements)/sizeof(*object_elements); ++j) {
			object_fieldnames[j] = object_elements[j];
		}
		
		mxArray *object_struct = mxCreateStructMatrix(1, 
													  1, 
													  sizeof(object_elements)/sizeof(*object_elements), 
													  object_fieldnames);
		
		mxArray *name = mxCreateString([[xro name] cStringUsingEncoding:NSASCIIStringEncoding]);		
		NSString *type_string = nil;
		switch([xro type]) {
			case FIDUCIAL:
				type_string = @"fiducial";
				break;
			case ELECTRODE:
				type_string = @"electrode";
				break;
			default:
				type_string = @"unknown";
				break;
		}
		
		mxArray *type = mxCreateString([type_string cStringUsingEncoding:NSASCIIStringEncoding]);		
		mxArray *visibility = mxCreateString([[xro visibility] cStringUsingEncoding:NSASCIIStringEncoding]);
		
		
		
		const char *center_elements [] = {"d1", "d2"};	
		Detector detectors [] = {DETECTOR_1, DETECTOR_2};
		const char **center_fieldnames = (const char **)calloc(sizeof(center_elements)/sizeof(*center_elements),
															   sizeof(const char *));
		//			const char **center_fieldnames = new const char *[sizeof(center_elements)/sizeof(*center_elements)];
		
		for(int j=0; j<sizeof(center_elements)/sizeof(*center_elements); ++j) {
			center_fieldnames[j] = center_elements[j];
		}
		
		mxArray *center_struct = mxCreateStructMatrix(1, 
													  1, 
													  sizeof(center_elements)/sizeof(*center_elements), 
													  center_fieldnames);
		
		for(int j=0; j<sizeof(center_elements)/sizeof(*center_elements); ++j) {
			const char *point_elements [] = {"x", "y"};
			const char **point_fieldnames = (const char **)calloc(sizeof(point_elements)/sizeof(*point_elements),
																  sizeof(const char *));
			//				const char **point_fieldnames = new const char *[sizeof(point_elements)/sizeof(*point_elements)];
			
			for(int k=0; k<sizeof(point_elements)/sizeof(*point_elements); ++k) {
				point_fieldnames[k] = point_elements[k];
			}
			
			mxArray *point_array = mxCreateStructMatrix(1, 
														1, 
														sizeof(point_elements)/sizeof(*point_elements), 
														point_fieldnames);
			
			NSPoint center = [[xro plotableObject] pointForDetector:detectors[j]];
			
			mxSetField(point_array, 0, "x", mxCreateDoubleScalar(center.x));					
			mxSetField(point_array, 0, "y", mxCreateDoubleScalar(center.y));
			mxSetField(center_struct, 0, center_elements[j], point_array);
			
			free(point_fieldnames);
		}
		
		const char *color_elements[] = {"red", "green", "blue", "alpha"};
		const char **color_fieldnames = (const char **)calloc(sizeof(color_elements)/sizeof(*color_elements),
															  sizeof(const char *));
		//			const char **color_fieldnames = new const char *[sizeof(color_elements)/sizeof(*color_elements)];
		
		for(int j=0; j<sizeof(color_elements)/sizeof(*color_elements); ++j) {
			color_fieldnames[j] = color_elements[j];
		}
		
		mxArray *color_struct = mxCreateStructMatrix(1, 
													 1, 
													 sizeof(color_elements)/sizeof(*color_elements), 
													 color_fieldnames);
		
		mxSetField(color_struct, 0, "red", mxCreateDoubleScalar([[[xro plotableObject] color] redComponent]));
		mxSetField(color_struct, 0, "green", mxCreateDoubleScalar([[[xro plotableObject] color] greenComponent]));
		mxSetField(color_struct, 0, "blue", mxCreateDoubleScalar([[[xro plotableObject] color] blueComponent]));
		mxSetField(color_struct, 0, "alpha", mxCreateDoubleScalar([[[xro plotableObject] color] alphaComponent]));
		
		mxSetField(object_struct, 0, "center", center_struct);
		mxSetField(object_struct, 0, "name", name);
		mxSetField(object_struct, 0, "color", color_struct);
		mxSetField(object_struct, 0, "type", type);
		mxSetField(object_struct, 0, "visibility", visibility);
		
		mxSetCell(xray_objects_array, i, object_struct);
		
		free(color_fieldnames);
		free(center_fieldnames);
		free(object_fieldnames);
	}
	
	NSString *elements_mat_path = [bundle_path stringByAppendingPathComponent:@"Image_processing/xray_elements.mat"];
	
	MATFile *elements_mat = matOpen([elements_mat_path cStringUsingEncoding:NSASCIIStringEncoding], "w");
	
	if(elements_mat == NULL) {
		[NSException raise:NSInternalInconsistencyException
					format:@"[FiducialWindowMATLABInterface write:toBundle] cannot open %@",
			elements_mat_path];
	}
	
	matPutVariable(elements_mat, "elements", xray_objects_array);
	matClose(elements_mat);
	
	// write the objects to the RHS file
	[self writeRHS:xray_objects
		  toBundle:bundle_path];
	
	mxDestroyArray(xray_objects_array);
}


+ (NSArray *)xrayElementsFromBundle:(NSString *)bundle_path {
	MATFile *xray_elements_file = matOpen([[bundle_path stringByAppendingPathComponent:@"Image_processing/xray_elements.mat"] cStringUsingEncoding:NSASCIIStringEncoding], 
										  "r");
	
	mxArray *elements = matGetVariable(xray_elements_file, "elements");
	
	NSMutableArray *xray_elements = [NSMutableArray array];
	
	for (int i=0; i<mxGetN(elements); ++i) {
		mxArray *element = mxGetCell(elements, i);
		
		mxArray *name_array = mxGetField(element, 0, "name");
		char *name_buf = (char *)calloc(mxGetNumberOfElements(name_array)+1, sizeof(char));
		mxGetString(name_array, name_buf, mxGetNumberOfElements(name_array)+1);
		
		NSString *name = [NSString stringWithCString:name_buf
											encoding:NSASCIIStringEncoding];
		
		mxArray *type_array = mxGetField(element, 0, "type");
		char *type_buf = (char *)calloc(mxGetNumberOfElements(type_array)+1, sizeof(char));
		mxGetString(type_array, type_buf, mxGetNumberOfElements(type_array)+1);
		
		NSString *type = [NSString stringWithCString:type_buf
											encoding:NSASCIIStringEncoding];
		
		XrayObject *xro=nil;
		if([[type lowercaseString] isEqualToString:@"electrode"]) {
			xro = [Electrode electrodeWithName:name];
		} else if([[type lowercaseString] isEqualToString:@"fiducial"]){
			mxArray *vis_array = mxGetField(element, 0, "visibility");
			char *vis_buf = (char *)calloc(mxGetNumberOfElements(vis_array)+1, sizeof(char));
			mxGetString(vis_array, vis_buf, mxGetNumberOfElements(vis_array)+1);
			
			NSString *visibility = [NSString stringWithCString:vis_buf
												encoding:NSASCIIStringEncoding];
			

			xro = [Fiducial fiducialWithName:name andVisibility:visibility];
				
			free(vis_buf);		
		}

		PlotableXrayObject *po = [xro plotableObject];
				
		Detector detectors[] = {DETECTOR_1, DETECTOR_2};
		for(int i=0; i < sizeof(detectors)/sizeof(*detectors); ++i) {
			NSString *detector_number = nil;
			switch(detectors[i]) {
				case DETECTOR_1:
					detector_number = @"d1";
					break;
				case DETECTOR_2:
					detector_number = @"d2";
					break;
				default:
					[NSException raise:NSInternalInconsistencyException
								format:@"Can't open xray bundle: %@", bundle_path];
					break;
			}			
			
			mxArray *center = mxGetField(element, 0, "center");			
			mxArray *detector = mxGetField(center, 0, [detector_number cStringUsingEncoding:NSASCIIStringEncoding]);
			
			mxArray *x = mxGetField(detector, 0, "x");
			mxArray *y = mxGetField(detector, 0, "y");
			
			[po setPoint:NSMakePoint(mxGetScalar(x),mxGetScalar(y)) forDetector:detectors[i]];
		}
		mxArray *color = mxGetField(element, 0, "color");
		mxArray *red = mxGetField(color, 0, "red");
		mxArray *green = mxGetField(color, 0, "green");
		mxArray *blue = mxGetField(color, 0, "blue");
		mxArray *alpha = mxGetField(color, 0, "alpha");
		[po setColor:[NSColor colorWithCalibratedRed:mxGetScalar(red) 
											   green:mxGetScalar(green) 
												blue:mxGetScalar(blue) 
											   alpha:mxGetScalar(alpha)]];
		
		[xray_elements addObject:xro];
		
		free(type_buf);		
		free(name_buf);		
	}
	
	mxDestroyArray(elements);
	matClose(xray_elements_file);
	
	return xray_elements;
}

// private methods
+ (void)writeRHS:(NSArray *)xray_objects
		toBundle:(NSString *)bundle_path {
	
	const int NUM_DETECTORS=2;
	
	// first get the images
	CocoaMxArray *d1_image = [self raw2mat:bundle_path forDetector:DETECTOR_1];
	CocoaMxArray *d2_image = [self raw2mat:bundle_path forDetector:DETECTOR_2];
	NSSize image_size[NUM_DETECTORS];
	image_size[0] = NSMakeSize(mxGetN([d1_image array]), mxGetM([d1_image array]));
	image_size[1] = NSMakeSize(mxGetN([d2_image array]), mxGetM([d2_image array]));
	
	const char *rhs_elements[] = {"detector1Projection",
		"detector2Projection",
		"detector1",
		"detector2",
		"numFids",
		"numDetectors"};
	const char **rhs_fieldnames = (const char **)calloc(sizeof(rhs_elements)/sizeof(*rhs_elements),
														sizeof(const char *));
	
	for(int i=0; i<sizeof(rhs_elements)/sizeof(*rhs_elements); ++i) {
		rhs_fieldnames[i]=rhs_elements[i];
	}
	
	mxArray *rhs_verbose = mxCreateStructMatrix(1,
												1,
												sizeof(rhs_elements)/sizeof(*rhs_elements), 
												rhs_fieldnames);
	mxSetField(rhs_verbose, 0, "detector1Projection", mxDuplicateArray([d1_image array]));
	mxSetField(rhs_verbose, 0, "detector2Projection", mxDuplicateArray([d2_image array]));
	mxSetField(rhs_verbose, 0, "numDetectors", mxCreateDoubleScalar(NUM_DETECTORS));
	
	mxArray *detector_object_array[NUM_DETECTORS];
	for(int j=0; j<NUM_DETECTORS; ++j) {
		detector_object_array[j] = mxCreateStructMatrix(1,1,0,0);
	}
	
	NSEnumerator *xro_enumerator = [xray_objects objectEnumerator];
	XrayObject *xro = nil;
	int current_object_index = 0;
	int projection_number = 0;
	
	while(xro = [xro_enumerator nextObject]) {		
		++current_object_index;
		if([[xro plotableObject] pointForDetector:DETECTOR_1].x > 0 && 
		   [[xro plotableObject] pointForDetector:DETECTOR_1].y > 0 &&
		   [[xro plotableObject] pointForDetector:DETECTOR_2].x > 0 && 
		   [[xro plotableObject] pointForDetector:DETECTOR_2].y > 0) {
			
			NSString *object_name = [NSString stringWithFormat:@"fiducial%dProjection", ++projection_number];

			for(int j=0; j<NUM_DETECTORS; ++j) {
				const char *object_point_elements[] = {"x", "y", "index"};
				const char **object_point_fieldnames = (const char **)calloc(sizeof(object_point_elements)/sizeof(*object_point_elements),
																			 sizeof(const char *));
				
				for(int k=0; k<sizeof(object_point_elements)/sizeof(*object_point_elements); ++k) {
					object_point_fieldnames[k]=object_point_elements[k];
				}
				
				mxArray *point_array = mxCreateStructMatrix(1,
															1,
															sizeof(object_point_elements)/sizeof(*object_point_elements), 
															object_point_fieldnames);
				
				
				Detector detector = UNDEFINED_DETECTOR;
				switch(j) {
					case 0:
						detector = DETECTOR_1;
						break;
					case 1:
						detector = DETECTOR_2;
						break;
					default:
						[NSException raise:NSInternalInconsistencyException
									format:@"Too many detectors in [FiducialWindowMATLABInterface writeRHS:toBundle:"];
						break;
				}
				
				GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
				NSPoint center = [engine MATLABPointFromXrayPoint:[[xro plotableObject] pointForDetector:detector]
												   usingImageSize:image_size[j]];
				[engine unlock];
				
				mxSetField(point_array, 0, "x", mxCreateDoubleScalar(center.x));					
				mxSetField(point_array, 0, "y", mxCreateDoubleScalar(center.y));
				mxSetField(point_array, 0, "index", mxCreateDoubleScalar(current_object_index));
				
				mxAddField(detector_object_array[j],
						   [object_name cStringUsingEncoding:NSASCIIStringEncoding]);
				mxSetField(detector_object_array[j], 
						   0, 
						   [object_name cStringUsingEncoding:NSASCIIStringEncoding], 
						   point_array);
				
				free(object_point_fieldnames);
			}
		}
	}
	
	mxSetField(rhs_verbose, 0, "detector1", detector_object_array[0]);
	mxSetField(rhs_verbose, 0, "detector2", detector_object_array[1]);
	mxSetField(rhs_verbose, 
			   0, 
			   "numFids", 
               mxCreateDoubleScalar(projection_number));
	
	NSString *RHS_path = [bundle_path stringByAppendingPathComponent:@"Image_processing/RHS.mat"];
	MATFile *rhs_mat_file = matOpen([RHS_path cStringUsingEncoding:NSASCIIStringEncoding], 
									"w");
	if(rhs_mat_file == NULL) {
		[NSException raise:NSInternalInconsistencyException
					format:@"[FiducialWindowMATLABInterface writeRHS:toBundle:] Cannot open RHS file %@", 
			RHS_path];		
	}
	
	matPutVariable(rhs_mat_file, "RHS_Verbose", rhs_verbose);
	
	matClose(rhs_mat_file);
	
	mxDestroyArray(rhs_verbose);	
	free(rhs_fieldnames);
}


+ (CocoaMxArray *)raw2mat:(NSString *)bundle_path
			  forDetector:(Detector)detector {
	
	NSString *raw_file = nil;
	switch(detector) {
		case DETECTOR_1:
			raw_file = @"d1.raw";
			break;
		case DETECTOR_2:
			raw_file = @"d2.raw";
			break;
		default:
			[NSException raise:NSInternalInconsistencyException
						format:@"[FiducialWindowMATLABInterface raw2mat:forDetector] has illegal detector"];
			break;
	}
	NSString *raw_path = [[bundle_path stringByAppendingPathComponent:@"Image_processing"] stringByAppendingPathComponent:raw_file];
	
	NSString *image_variable = @"image";
	
#ifdef __ppc__
	NSString *raw2mat_command = [NSString stringWithFormat:@"%@=raw2mat_ppc('%@');",
		image_variable,
		raw_path];
#else
	NSString *raw2mat_command = [NSString stringWithFormat:@"%@=raw2mat('%@');",
		image_variable,
		raw_path];	
#endif
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	[engine evalString:raw2mat_command];
	
	CocoaMxArray *image_array = [engine getVariableValue:image_variable];
	[engine unlock];
	
	return image_array;
}



@end
