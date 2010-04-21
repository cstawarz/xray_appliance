//
//  TransformableObject.h
//  XRIPT
//
//  Created by bkennedy on 7/8/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TransformableObject : NSObject <NSCopying> {
	double translation[3];	
	double rotation[3];
}

- (id) initWithTranslation:(double *)new_translation 
			   andRotation:(double *)new_rotation;

+ (id) objectWithTranslation:(double *)new_translation 
				 andRotation:(double *)new_rotation;

- (double *)translation;
- (double *)rotation;

@end
