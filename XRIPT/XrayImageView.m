

#import "XrayImageView.h"
#import "NSImage-ProportionalImage.h"
#import "XrayImageWindowController.h"

@interface XrayImageView (PrivateMethods)
- (NSRect)imageViewFrame;
@end

@implementation XrayImageView

- (void)awakeFromNib {
	making_selection = NO;
	selected_region = NSMakeRect(0,0,0,0);
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)new_delegate {
	if (![new_delegate respondsToSelector:@selector(enableControls)] ||
		![new_delegate respondsToSelector:@selector(selectObjectAtPoint:)] ||
		![new_delegate respondsToSelector:@selector(pointMovedByX: andY:)] ||
		![new_delegate respondsToSelector:@selector(pointsMovedByX: andY:)] ||
		![new_delegate respondsToSelector:@selector(endMovePoints)] ||
		![new_delegate respondsToSelector:@selector(pointSelected:)] ||
		![new_delegate respondsToSelector:@selector(regionSelected:)] ||
		![new_delegate respondsToSelector:@selector(pathsAndColorsWithBounds:)]) {
		[NSException raise:NSInternalInconsistencyException 
					format:@"Delegate doesn't respond to required methods for XRayImageView"];			
	}
	
    delegate = new_delegate;
}

- (void)mouseDown:(NSEvent *)the_event {
	if([delegate enableControls]) {
		making_selection = YES;
		BOOL keep_on = YES;
		BOOL is_inside = YES;
		BOOL dragging = NO;
		NSPoint start_point = [self convertPoint:[the_event locationInWindow] fromView:nil];
		
		unsigned int modifier_flags = [the_event modifierFlags];
		
		BOOL object_selected = NO;
		
		if(!(modifier_flags & NSControlKeyMask)) {
			NSRect image_view_frame = [self imageViewFrame];
			object_selected = [delegate selectObjectAtPoint:NSMakePoint((start_point.x-image_view_frame.origin.x)/image_view_frame.size.width,
																		(start_point.y-image_view_frame.origin.y)/image_view_frame.size.height)];
		}
		
		while (keep_on) {
			
			the_event = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
			NSPoint mouse_location = [self convertPoint:[the_event locationInWindow] fromView:nil];
			is_inside = [self mouse:mouse_location inRect:[[self cell] drawingRectForBounds:[self bounds]]];
			
			NSRect bounds = [self bounds];
			
			mouse_location.x = mouse_location.x < bounds.origin.x ? bounds.origin.x : mouse_location.x;
			mouse_location.y = mouse_location.y < bounds.origin.y ?bounds.origin.y : mouse_location.y;
			
			mouse_location.x = mouse_location.x > bounds.size.width-bounds.origin.x ? bounds.size.width-bounds.origin.x : mouse_location.x;
			mouse_location.y = mouse_location.y > bounds.size.height-bounds.origin.y ? bounds.size.height-bounds.origin.y : mouse_location.y;
			
			if (modifier_flags & NSControlKeyMask) {
				switch ([the_event type]) {
					case NSLeftMouseDragged:
					{
						dragging = YES;
						
						NSRect image_view_frame = [self imageViewFrame];
						
						float x_difference = (mouse_location.x - start_point.x)/image_view_frame.size.width;
						float y_difference = (mouse_location.y - start_point.y)/image_view_frame.size.height;
						
						[delegate pointsMovedByX:x_difference andY:y_difference];
						
						[self setNeedsDisplay:YES];
						
						start_point = mouse_location;
						
						break;
					}
					case NSLeftMouseUp:
					{
						keep_on = NO;
						making_selection = NO;
						dragging = NO;
						
						[delegate endMovePoints];
						[self setNeedsDisplay:YES];
						break;
					}
					default:
						// Ignore any other kind of event.
						break;
				}		
			} else {
				switch ([the_event type]) {
					case NSLeftMouseDragged:
						dragging = YES;
						if(object_selected) {
							NSRect image_view_frame = [self imageViewFrame];
														
							float x_difference = (mouse_location.x - start_point.x)/image_view_frame.size.width;
							float y_difference = (mouse_location.y - start_point.y)/image_view_frame.size.height;
							
							[delegate pointMovedByX:x_difference andY:y_difference];
							
							start_point = mouse_location;
						} else {
						//set the current selection rectangle
							NSPoint hlPoint = NSMakePoint(MIN(mouse_location.x, start_point.x), 
														  MIN(mouse_location.y, start_point.y));
							NSPoint endPoint = NSMakePoint(MAX(mouse_location.x, start_point.x), 
														   MAX(mouse_location.y, start_point.y));
							
							selected_region = NSMakeRect(hlPoint.x,
														 hlPoint.y,
														 endPoint.x-hlPoint.x,
														 endPoint.y-hlPoint.y);
						}
						[self setNeedsDisplay:YES];
						break;
					case NSLeftMouseUp:
						if([self image]) {					
							NSRect image_view_frame = [self imageViewFrame];
							
							if(is_inside && 
							   [self mouse:mouse_location inRect:image_view_frame] &&
							   [self mouse:start_point inRect:image_view_frame]) {
								
								if(mouse_location.x == start_point.x && mouse_location.y == start_point.y && !dragging) {
									// a point was clicked
									if(delegate != nil) {
										[delegate pointSelected:NSMakePoint((mouse_location.x-image_view_frame.origin.x)/image_view_frame.size.width,
																			(mouse_location.y-image_view_frame.origin.y)/image_view_frame.size.height)];
									}
								} else {
									if(selected_region.size.width > 0 && selected_region.size.height > 0 && dragging) {	
										// a region was selected
										if(delegate != nil) {
											[delegate regionSelected: NSMakeRect((selected_region.origin.x-image_view_frame.origin.x)/image_view_frame.size.width,
																				 (selected_region.origin.y-image_view_frame.origin.y)/image_view_frame.size.height,
																				 selected_region.size.width/image_view_frame.size.width,
																				 selected_region.size.height/image_view_frame.size.height)];
										}
									}
								}						
							}
						}
						keep_on = NO;
						making_selection = NO;
						dragging = NO;
						selected_region = NSMakeRect(0,0,0,0);
						
						
						[delegate endMovePoints];
						[self setNeedsDisplay:YES];
						break;
					default:
						// Ignore any other kind of event.
						break;
				}
			}		
		}
	}
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	
	
	// this could be smarter....get the important view data from the delegate rather 
	// looping twice (once to construct the paths, once to go through the paths)
	NSEnumerator *path_enumerator = [[delegate pathsAndColorsWithBounds:[self imageViewFrame]] objectEnumerator];
	NSDictionary *path_and_color;
	
	while(path_and_color = [path_enumerator nextObject]) {
		[(NSColor *)[path_and_color objectForKey:XRAY_OBJECT_COLOR] set];
		[(NSBezierPath *)[path_and_color objectForKey:XRAY_OBJECT_PATH] stroke];
	}
	
	if(making_selection) {
		[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.2] set];
		[[NSBezierPath bezierPathWithRect:selected_region] fill];
	}
}
////////////////////////////////////////////////////////////////////////////////
// private methods
////////////////////////////////////////////////////////////////////////////////

// returns the actual pixes (within this NSImageView) of the image displayed
- (NSRect)imageViewFrame {
	NSSize actual_size = [[self image] size];
	float actual_height_width_ratio = actual_size.height/actual_size.width;
	
	NSRect visible_image_bounds = [[self cell] drawingRectForBounds:[self bounds]];
	float visible_height_width_ratio = visible_image_bounds.size.height/visible_image_bounds.size.width;
	
	float width=0;
	float height=0;
	float x=0;
	float y=0;
	
	if(actual_height_width_ratio > visible_height_width_ratio) {
		// the image is limited by height
		float scale_factor = visible_image_bounds.size.height/actual_size.height;
		x = (visible_image_bounds.size.width-(actual_size.width*scale_factor))/2 + visible_image_bounds.origin.x;
		y = visible_image_bounds.origin.y;
		width = actual_size.width*scale_factor;
		height = visible_image_bounds.size.height; 
	} else {
		// the image is limited by width
		float scale_factor = visible_image_bounds.size.width/actual_size.width;
		
		x = visible_image_bounds.origin.x;
		y = (visible_image_bounds.size.height-(actual_size.height*scale_factor))/2 + visible_image_bounds.origin.y;
		width = visible_image_bounds.size.width;
		height = actual_size.height*scale_factor; 
	}
	
	return NSMakeRect(x, y, width, height);
}


@end
