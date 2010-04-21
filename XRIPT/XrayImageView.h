/* XrayImageView */

#import <Cocoa/Cocoa.h>

@interface XrayImageView : NSImageView
{
	NSRect selected_region;
	BOOL making_selection;
	IBOutlet id delegate;
}


- (id)delegate;
- (void)setDelegate:(id)newDelegate;

@end