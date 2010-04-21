//
//  ProjectToCRV.m
//  XRayBox
//
//  Created by Ben Kennedy on 2/4/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "ProjectToCRV.h"
#import "GlobalMATLABEngine.h"


@implementation ProjectToCRV

+ (void)projectElement:(NSString *)element_to_project_name
			   toFrame:(NSString *)frame_to_project_to
			  toBundle:(NSString *)current_bundle_path
			  usingCRV:(CocoaMxArray *)crv {
	[self projectElement:element_to_project_name
				 toFrame:frame_to_project_to
				toBundle:current_bundle_path
				usingCRV:crv
			  andOverlay:nil
			  andOpacity:0];
}

+ (void)projectElement:(NSString *)element_to_project_name
			   toFrame:(NSString *)frame_to_project_to
			  toBundle:(NSString *)current_bundle_path
			  usingCRV:(CocoaMxArray *)crv
			andOverlay:(CocoaMxArray *)overlay_crv
			andOpacity:(float)overlay_opacity {
	// figure this out from the bundle
	MATFile *coreg_data_file = matOpen([[current_bundle_path stringByAppendingPathComponent:@"3D_reconstruction/matlabCoregData.mat"] cStringUsingEncoding:NSASCIIStringEncoding], 
								  "r");
	
	if(coreg_data_file == NULL) {
		return;
	}
	
	mxArray *coreg_data = matGetVariable(coreg_data_file, "CoregData");
	
	if(coreg_data == NULL) { 
		return;
	}
	
	matClose(coreg_data_file);
	
	mxArray *data_elements_in_all_frames = mxGetField(coreg_data, 0, "dataElementsInAllFrames");
	
	mxArray *frame_to_project = NULL;
	
	for(int i=0; i<mxGetNumberOfElements(data_elements_in_all_frames); ++i) {
		mxArray *frame = mxGetCell(data_elements_in_all_frames, i);
		
		mxArray *frame_name_array = mxGetField(frame, 0, "frameName");
		
		
		char *frame_name_buf = (char *)calloc(mxGetNumberOfElements(frame_name_array)+1, sizeof(char));
		mxGetString(frame_name_array, frame_name_buf, mxGetNumberOfElements(frame_name_array)+1);
		
		NSString *frame_name = [NSString stringWithCString:frame_name_buf
												   encoding:NSASCIIStringEncoding];
		
		//mxDestroyArray(frame_name_array);
		//mxDestroyArray(element);
		free(frame_name_buf);
		
		if([frame_to_project_to isEqualToString:frame_name]) {
			frame_to_project = frame;
			break;
		}
	}
	
	mxArray *elements = mxGetField(frame_to_project, 0, "elements");
	
	mxArray *location = NULL;
	for(int i=0; i<mxGetNumberOfElements(elements); ++i) {
		mxArray *element = mxGetCell(elements, i);
		
		mxArray *element_name_array = mxGetField(element, 0, "name");
		
		
		char *element_name_buf = (char *)calloc(mxGetNumberOfElements(element_name_array)+1, sizeof(char));
		mxGetString(element_name_array, element_name_buf, mxGetNumberOfElements(element_name_array)+1);
		
		NSString *element_name = [NSString stringWithCString:element_name_buf
												  encoding:NSASCIIStringEncoding];
		
		free(element_name_buf);
		
		if([element_to_project_name isEqualToString:element_name]) {
			location = mxGetField(element, 0, "location_um");
			break;
		}
	}
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	
	NSString *point_variable = @"point";
	NSString *crv_var = @"crv";
	[engine setVariable:crv
					 as:crv_var];
	
	
	NSString *cmd;
	
	if(overlay_crv != nil) {
		NSString *overlay_crv_var = @"overlay";
		
		[engine setVariable:overlay_crv
						 as:overlay_crv_var];
		
		cmd = [NSString stringWithFormat:@"viewCRV(%@, %@, '%@', %@, %f);", 
			crv_var, 
			point_variable, 
			frame_to_project_to,
			overlay_crv_var,
			overlay_opacity];
	} else {
		cmd = [NSString stringWithFormat:@"viewCRV(%@, %@, '%@');", 
			crv_var, 
			point_variable, 
			frame_to_project_to];		
	}
	
	[engine setVariable:[CocoaMxArray arrayWithMxArray:location]
					 as:point_variable];
	
	[engine evalString:cmd];
		
	[engine unlock];
	
	mxDestroyArray(coreg_data);
}


@end
