//
//  XrayXMLParser.m
//  XRIPT
//
//  Created by labuser on 7/24/08.
//  Copyright 2008 MIT. All rights reserved.
//

#import "XrayXMLDocument.h"


@implementation XrayXMLDocument

- (NSString *)valueStringForSingularXPath:(NSString *)xpath	{
	NSArray *nodes = [self nodesForXPath:xpath
								   error:nil];
	
	if([nodes count] != 1) {
		[NSException raise:NSInternalInconsistencyException
					format:@"fails xPath query: %@",
			xpath];			
	}
	return [[nodes objectAtIndex:0] stringValue];
}

@end
