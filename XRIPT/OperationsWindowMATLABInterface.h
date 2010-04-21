//
//  OperationsWindowMATLABInterface.h
//  XRIPT
//
//  Created by bkennedy on 3/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XrayBundle.h"
#import "CocoaMxArray.h"
#import "GlobalMATLABEngine.h"

@interface OperationsWindowMATLABInterface : NSObject {

}

+ (NSArray *)reconstructedObjectNamesForBundle:(XrayBundle *)bundle;
+ (CocoaMxArray *)getCRV:(NSString *)crv_path;

@end
