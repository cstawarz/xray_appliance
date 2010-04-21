//
//  OperationsWindowMATLABInterface.m
//  XRIPT
//
//  Created by bkennedy on 3/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "OperationsWindowMATLABInterface.h"
#import "mat.h"

@implementation OperationsWindowMATLABInterface

+ (NSArray *)reconstructedObjectNamesForBundle:(XrayBundle *)bundle {
	NSMutableArray *object_names = [NSMutableArray array];
	
	NSString *recon_native_filename = [[bundle path] stringByAppendingPathComponent:@"3D_reconstruction/recon_Native.mat"];
	
	MATFile *recon_native_file = matOpen([recon_native_filename cStringUsingEncoding:NSASCIIStringEncoding],
										 "r");
	
	if(recon_native_file != NULL) {
		mxArray *recon_centers = matGetVariable(recon_native_file, "recon_centers");
		
		
		if(recon_centers != NULL) {
			mxArray *elements = mxGetField(recon_centers, 0, "elements");
			
			for (int i=0; i < mxGetN(elements); ++i) {
				mxArray *element = mxGetCell(elements, i);
				
				mxArray *name = mxGetField(element, 0, "name");
				
				if(mxIsChar(name)) {
					int buflen = mxGetN(name) + 1;
					char *buffer = (char *)calloc(buflen, sizeof(char));					
					mxGetString(name, buffer, buflen);
					
					[object_names addObject:[NSString stringWithCString:buffer
															   encoding:NSASCIIStringEncoding]];
					
					free(buffer);
				}
			}

			mxDestroyArray(recon_centers);
			matClose(recon_native_file);
		}
	}
	
	return object_names;
}

+ (CocoaMxArray *)getCRV:(NSString *)crv_path {
	NSString *crv_var = @"crv";
	
	NSString *cmd = [NSString stringWithFormat:@"%@=getCRV('%@');", 
		crv_var, 
		crv_path];
	
	GlobalMATLABEngine *engine = [GlobalMATLABEngine lockedEngine];
	[engine evalString:cmd];
	
	CocoaMxArray *crv = [engine getVariableValue:crv_var];
	
	[engine unlock];
	
	return crv;
}

@end
