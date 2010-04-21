//
//  CoregisterToFrames.m
//  XRayBox
//
//  Created by Ben Kennedy on 2/4/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "CoregisterToFrames.h"
#import "CocoaFFOR.h"
#import "CocoaMxArray.h"
#import "GlobalMATLABEngine.h"

#define ELEMENT_NAME "name"
#define ELEMENT_LOCATION "location_um"
#define ELEMENT_VISIBILITY "visibility"

#define FRAME_NAME "name"
#define FRAME_ELEMENTS "elements"

@interface CoregisterToFrames (PrivateMethods)
+ (NSArray *)convertFrames:(NSArray *)frames;
@end

@implementation CoregisterToFrames
+ (BOOL)coregisterBundle:(NSString *)bundle_path
			 usingFrames:(NSArray *)frames_to_use {
	
	NSArray *converted_frames = [CoregisterToFrames convertFrames:frames_to_use];
	
	mxArray *MATLAB_frames = mxCreateCellMatrix(1, [converted_frames count]);
	
	NSEnumerator *enumerator = [converted_frames objectEnumerator];
	CocoaMxArray *MATLAB_frame;
	int frame_num = 0;
	
	while(MATLAB_frame = [enumerator nextObject]) {
		mxArray *mx_frame = mxDuplicateArray([MATLAB_frame array]);
		
		mxSetCell(MATLAB_frames, frame_num, mx_frame);
		++frame_num;
	}
		
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	
	NSString *transform_package_variable = @"transform_package";
	NSString *error_variable = @"err";
	NSString *frames_variable = @"frames";
	
	[engine setVariable:[CocoaMxArray arrayWithMxArray:MATLAB_frames]
					 as:frames_variable];	

	NSString *cmd = [NSString stringWithFormat:@"[%@, %@] = runCoregistration('%@', %@);", 
		transform_package_variable, 
		error_variable, 
		bundle_path, 
		frames_variable];
	
	[engine evalString:cmd];

	[engine unlock];

	mxDestroyArray(MATLAB_frames);
	
	return [self isBundleCoregistered:bundle_path toFrames:frames_to_use];
}

+ (NSArray *)convertFrames:(NSArray *)frames {
	NSMutableArray *converted_frames = [[NSMutableArray alloc] init];
	
	NSEnumerator *frame_enumerator = [frames objectEnumerator];
	CocoaFFOR *frame = nil;
	
	while(frame = [frame_enumerator nextObject]) {
		const char *frame_field_names[] = {FRAME_NAME, FRAME_ELEMENTS};
		int frame_nfields = sizeof(frame_field_names)/sizeof(*frame_field_names);
		
		// this might need to be mwSize for intel platforms
		mwSize frame_dims = 1;
		mxArray *MATLAB_frame = mxCreateStructArray(1, 
													&frame_dims, 
													frame_nfields, 
													frame_field_names);
		
		// set frame.name
		mxSetField(MATLAB_frame, 
				   0, 
				   FRAME_NAME, 
				   mxCreateString([[frame name] cStringUsingEncoding:NSASCIIStringEncoding]));
		
		// create and set frame.elements
		mxArray *elements_vector = mxCreateCellMatrix(1, [[frame elements] count]);
			
		NSEnumerator *element_enumerator = [[frame elements] objectEnumerator];
		NSDictionary *element = nil;
		
		int i=0;
		while(element = [element_enumerator nextObject]) {
			const char *element_field_names[] = {ELEMENT_NAME, ELEMENT_LOCATION, ELEMENT_VISIBILITY};
			int element_nfields = sizeof(element_field_names)/sizeof(*element_field_names);
			
			// this might need to be mwSize for intel platforms
			mwSize element_dims = 1;
			mxArray *MATLAB_element = mxCreateStructArray(1, 
														&element_dims, 
														element_nfields, 
														element_field_names);
			
			mxSetField(MATLAB_element, 
					   0, 
					   ELEMENT_NAME, 
					   mxCreateString([[element objectForKey:FFOR_ELEMENT_NAME] cStringUsingEncoding:NSASCIIStringEncoding]));
			
			
			mxSetField(MATLAB_element, 
					   0, 
					   ELEMENT_VISIBILITY, 
					   mxCreateString([[element objectForKey:FFOR_ELEMENT_VISIBILITIES] cStringUsingEncoding:NSASCIIStringEncoding]));
			
			// create a vector that contains the location
			mxArray *location_vector = mxCreateNumericMatrix(1, 
															 3, 
															 mxDOUBLE_CLASS,
															 mxREAL);
			
			double *location_vector_data = mxGetPr(location_vector);
			location_vector_data[0]=[[element objectForKey:FFOR_ELEMENT_X] doubleValue];
			location_vector_data[1]=[[element objectForKey:FFOR_ELEMENT_Y] doubleValue];
			location_vector_data[2]=[[element objectForKey:FFOR_ELEMENT_Z] doubleValue];
			
			mxSetField(MATLAB_element, 
					   0, 
					   ELEMENT_LOCATION, 
					   location_vector);
			
			mxSetCell(elements_vector, i, MATLAB_element);
			++i;
		}
		
		mxSetField(MATLAB_frame, 0, FRAME_ELEMENTS, elements_vector);
		
		[converted_frames addObject:[CocoaMxArray arrayWithMxArray:MATLAB_frame]];
		mxDestroyArray(MATLAB_frame);
	}
	return converted_frames;
}

+ (BOOL)isBundleCoregistered:(NSString *)bundle_path toFrames:(NSArray *)frames {
	if([frames count] <= 0) {
		return NO;
	}
	
	CocoaFFOR *frame = nil;
	NSEnumerator *enumerator = [frames objectEnumerator];
	
	while(frame = [enumerator nextObject]) {
		NSString *reconstruction_directory = [bundle_path stringByAppendingPathComponent:@"3D_reconstruction"];
		NSString *recon_file_name = [[@"recon_" stringByAppendingString:[frame name]] stringByAppendingPathExtension:@"mat"];
		NSString *recon_file_path = [reconstruction_directory stringByAppendingPathComponent:recon_file_name];
		
		MATFile *recon_file = matOpen([recon_file_path cStringUsingEncoding:NSASCIIStringEncoding], "r");
		if(recon_file == NULL) {
			return NO;
		}
		
		mxArray *recon_centers = matGetVariable(recon_file, "recon_centers");
		matClose(recon_file);
		if(recon_centers == NULL) {
			return NO;
		}
		
		if(!mxIsStruct(recon_centers)) {
			mxDestroyArray(recon_centers);
			return NO;
		}
		
		
		mxArray *elements = mxGetField(recon_centers, 0, "elements");
		if(elements == NULL) {
			mxDestroyArray(recon_centers);
			return NO;
		}
		
		if(mxGetClassID(elements) != mxCELL_CLASS) {
			mxDestroyArray(recon_centers);
			return NO;		
		}
		
		BOOL retval = YES;
		
		for (int i = 0; i < mxGetN(elements); ++i) {
			mxArray *element = mxGetCell(elements, i);
			
			
			mxArray *name = mxGetField(element, 0, "name");
			if(mxGetClassID(name) != mxCHAR_CLASS) {
				retval = NO;
			}
			
			mxArray *location_um = mxGetField(element, 0, "location_um");
			if(!mxIsNumeric(location_um)) retval = NO;
			if(mxGetN(location_um) != 3) retval = NO;
		}
		
		mxDestroyArray(recon_centers);
	}
	
	return YES;
}
@end
