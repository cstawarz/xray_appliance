//
//  TransformableObject.m
//  XRIPT
//
//  Created by bkennedy on 7/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "TransformableObject.h"


@implementation TransformableObject

- (id) initWithTranslation:(double *)new_translation 
			   andRotation:(double *)new_rotation {
	self = [super init];
	if (self != nil) {
		for (int i=0; i<3; ++i) {
			translation[i]=new_translation[i];
			rotation[i]=new_rotation[i];
		}
	}
	return self;	
}


+ (id)objectWithTranslation:(double *)new_translation 
				andRotation:(double *)new_rotation {
	return [[self alloc] initWithTranslation:new_translation
                                 andRotation:new_rotation];
}

- (double *)translation {
	return translation;
}

- (double *)rotation {
	return rotation;
}

- (id)copyWithZone:(NSZone *)zone {
    TransformableObject *copy = [[[self class] allocWithZone: zone]
            initWithTranslation:[self translation]
					andRotation:[self rotation]];
    return copy;
}

@end
