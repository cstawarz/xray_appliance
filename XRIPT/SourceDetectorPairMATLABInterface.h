//
//  SourceDetectorPairMATLABInterface.h
//  XRIPT
//
//  Created by labuser on 7/9/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SourceDetectorPair.h"
#import "CocoaMxArray.h"


@interface SourceDetectorPairMATLABInterface : NSObject {
}

+ (CocoaMxArray *)toMxArray:(SourceDetectorPair *)sdp;

@end
