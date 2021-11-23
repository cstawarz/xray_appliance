//
//  SourceDetectorPair.m
//  XRIPT
//
//  Created by bkennedy on 7/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "SourceDetectorPair.h"


@implementation SourceDetectorPair

- (id) initWithTranslation:(double *)new_translation
				  rotation:(double *)new_rotation
					source:(TransformableObject *)new_source 
			   andDetector:(TransformableObject *)new_detector {
	self = [super initWithTranslation:new_translation andRotation:new_rotation];
	if (self != nil) {
		source = [new_source copy];
		detector = [new_detector copy];
	}
	return self;
}

+ (id)sdpWithTranslation:(double *)new_translation
				rotation:(double *)new_rotation
				  source:(TransformableObject *)new_source 
			 andDetector:(TransformableObject *)new_detector {
	return [[self alloc] initWithTranslation:new_translation
									 rotation:new_rotation
									   source:new_source
								  andDetector:new_detector];
}


- (TransformableObject *)source {
	return source;
}

- (TransformableObject *)detector {
	return detector;
}

- (id)copyWithZone:(NSZone *)zone {
    TransformableObject *copy = [[[self class] allocWithZone: zone]
            initWithTranslation:[self translation]
					   rotation:[self rotation]
						 source:[self source]
					andDetector:[self detector]];
    return copy;
}

@end
