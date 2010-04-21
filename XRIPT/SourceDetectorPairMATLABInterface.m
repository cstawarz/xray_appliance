//
//  SourceDetectorPairMATLABInterface.m
//  XRIPT
//
//  Created by labuser on 7/9/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "SourceDetectorPairMATLABInterface.h"
#import "mat.h"

@interface SourceDetectorPairMATLABInterface(PrivateMethods)
+ (CocoaMxArray *)toVector:(double *)values 
				  withSize:(int)size;
+ (CocoaMxArray *)toTO:(TransformableObject *)to;
@end

@implementation SourceDetectorPairMATLABInterface

+ (CocoaMxArray *)toMxArray:(SourceDetectorPair *)sdp {
	const char *sdp_elements [] = {"translation", "rotation", "source","detector"};
	const char **sdp_fieldnames = (const char **)calloc(sizeof(sdp_elements)/sizeof(*sdp_elements),
														sizeof(const char *));		
	for(int j=0; j<sizeof(sdp_elements)/sizeof(*sdp_elements); ++j) {
		sdp_fieldnames[j] = sdp_elements[j];
	}
	
	mxArray *sdp_struct = mxCreateStructMatrix(1, 
											   1, 
											   sizeof(sdp_elements)/sizeof(*sdp_elements), 
											   sdp_fieldnames);
	
	
	
	// sdp translation
	double *translation = [sdp translation];
	mxSetField(sdp_struct, 0, "translation", mxDuplicateArray([[self toVector:translation
																	 withSize:3] array]));
	// sdp rotation
	double *rotation = [sdp rotation];
	mxSetField(sdp_struct, 0, "rotation", mxDuplicateArray([[self toVector:rotation
																	 withSize:3] array]));
	
	// sdp source
	mxSetField(sdp_struct, 0, "source", mxDuplicateArray([[self toTO:[sdp source]] array]));
	// sdp detector
	mxSetField(sdp_struct, 0, "detector", mxDuplicateArray([[self toTO:[sdp detector]] array]));
	
	CocoaMxArray *retval = [CocoaMxArray arrayWithMxArray:sdp_struct];	
	mxDestroyArray(sdp_struct);	
	free(sdp_fieldnames);
	return retval;
}

// create a mxArray with 3 values
+ (CocoaMxArray *)toVector:(double *)values 
				  withSize:(int)size {
	mxArray *vector = mxCreateDoubleMatrix(1, size, mxREAL);
	
	memcpy(mxGetPr(vector), values, size*sizeof(double));
	
	CocoaMxArray *retval = [CocoaMxArray arrayWithMxArray:vector];
	
	mxDestroyArray(vector);
	
	return retval;
}


// create a transformable object mxArray
+ (CocoaMxArray *)toTO:(TransformableObject *)to {
	const char *to_elements [] = {"translation", "rotation"};
	const char **to_fieldnames = (const char **)calloc(sizeof(to_elements)/sizeof(*to_elements),
													   sizeof(const char *));		
	for(int j=0; j<sizeof(to_elements)/sizeof(*to_elements); ++j) {
		to_fieldnames[j] = to_elements[j];
	}
	
	mxArray *to_struct = mxCreateStructMatrix(1, 
											  1, 
											  sizeof(to_elements)/sizeof(*to_elements), 
											  to_elements);
	
	// to translation
	double *translation = [to translation];
	mxSetField(to_struct, 0, "translation", mxDuplicateArray([[self toVector:translation
																	 withSize:3] array]));
	// to rotation
	double *rotation = [to rotation];
	mxSetField(to_struct, 0, "rotation", mxDuplicateArray([[self toVector:rotation
																  withSize:3] array]));
	
	
	CocoaMxArray *retval = [CocoaMxArray arrayWithMxArray:to_struct];	
	mxDestroyArray(to_struct);	
	free(to_fieldnames);
	return retval;
}

@end
