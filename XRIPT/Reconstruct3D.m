//
//  Reconstruct3D.m
//  XRayBox
//
//  Created by Ben Kennedy on 1/28/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "Reconstruct3D.h"
#import "mat.h"
#import "engine.h"
#import "GlobalMATLABEngine.h"
#import "XrayBundle.h"
#import "SourceDetectorPairMATLABInterface.h"

@implementation Reconstruct3D

+ (BOOL)reconstructBundle:(NSString *)bundle_path {
	XrayBundle *bundle = [XrayBundle bundleAtPath:bundle_path];

	NSArray *sdps = [[bundle calibration] sourceDetectorPairs];
	
	NSEnumerator *sdps_enumerator = [sdps objectEnumerator];
	SourceDetectorPair *sdp = nil;
	
	mxArray *sdps_array = mxCreateCellMatrix(1, [sdps count]);
	mwIndex index = 0;

	while(sdp = [sdps_enumerator nextObject]) {
		CocoaMxArray *sdp_mx_array = [SourceDetectorPairMATLABInterface toMxArray:sdp];
		mxSetCell(sdps_array, index, mxDuplicateArray([sdp_mx_array array]));
		index++;
	}
	

	NSString *system_geometry_variable = @"system_geometry";
	NSString *recon_output_variable = @"recon_centers";

	float rotation_spread = [[bundle calibration] guessRotationSpread];

	
	NSString *detector_distances_string = @"[";
	NSEnumerator *detector_distances_enumerator = [[[bundle calibration] guessDetectorDistances] objectEnumerator];
	NSNumber *detector_distance = nil;
	
	while(detector_distance = [detector_distances_enumerator nextObject]) {
		detector_distances_string = [detector_distances_string stringByAppendingString:[detector_distance stringValue]];
		detector_distances_string = [detector_distances_string stringByAppendingString:@" "];
	}
	detector_distances_string = [detector_distances_string stringByAppendingString:@"]"];
	
	NSString *source_distances_string = @"[";
	NSEnumerator *source_distances_enumerator = [[[bundle calibration] guessSourceDistances] objectEnumerator];
	NSNumber *source_distance = nil;
	
	while(source_distance = [source_distances_enumerator nextObject]) {
		source_distances_string = [source_distances_string stringByAppendingString:[source_distance stringValue]];
		source_distances_string = [source_distances_string stringByAppendingString:@" "];
	}
	source_distances_string = [source_distances_string stringByAppendingString:@"]"];
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];

	[engine setVariable:[CocoaMxArray arrayWithMxArray:sdps_array]
												as:system_geometry_variable];

	NSString *reconstruct_bundle_command = [NSString stringWithFormat:@"%@=reconstructBundle(%@, %f, %@, %@, '%@');",
		recon_output_variable,
		system_geometry_variable,
		rotation_spread,
		detector_distances_string,
		source_distances_string,
		bundle_path];

	[engine evalString:reconstruct_bundle_command];

	CocoaMxArray *recon_centers = [engine getVariableValue:recon_output_variable];
	[engine unlock];

	MATFile *recon_native_file = matOpen([[bundle_path stringByAppendingPathComponent:@"3D_reconstruction/recon_Native.mat"] cStringUsingEncoding:NSASCIIStringEncoding], 
										 "w");

	if(recon_native_file) {
		matPutVariable(recon_native_file, "recon_centers", [recon_centers array]);
		matClose(recon_native_file);		
	}

	mxDestroyArray(sdps_array);

	
	return [self isReconstructionAvailable:bundle_path];
}

// private methods
+ (BOOL)isReconstructionAvailable:(NSString *)bundle_path {
	NSString *recon_file = [bundle_path stringByAppendingPathComponent:@"3D_reconstruction/recon_Native.mat"];
	
	MATFile *recon_native_file = matOpen([recon_file cStringUsingEncoding:NSASCIIStringEncoding], "r");
	if(recon_native_file == NULL) {
		return NO;
	}
	
	mxArray *recon_centers = matGetVariable(recon_native_file, "recon_centers");
	matClose(recon_native_file);
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

	return retval;
}


@end
