//
//  SourceDetectorPair.h
//  XRIPT
//
//  Created by bkennedy on 7/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TransformableObject.h"

@interface SourceDetectorPair : TransformableObject {
	TransformableObject *source;
	TransformableObject *detector;
}

- (id) initWithTranslation:(double *)new_translation
				  rotation:(double *)new_rotation
					source:(TransformableObject *)new_source 
			   andDetector:(TransformableObject *)new_detector;

+ (id)sdpWithTranslation:(double *)new_translation
				rotation:(double *)new_rotation
				  source:(TransformableObject *)new_source 
			 andDetector:(TransformableObject *)new_detector;

- (TransformableObject *)source;
- (TransformableObject *)detector;

@end
