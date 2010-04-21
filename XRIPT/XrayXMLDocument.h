//
//  XrayXMLParser.h
//  XRIPT
//
//  Created by labuser on 7/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XrayXMLDocument : NSXMLDocument {

}

- (NSString *)valueStringForSingularXPath:(NSString *)xpath;

@end
