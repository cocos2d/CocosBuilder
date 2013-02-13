//
//  SequencerPopoverHandler.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/12/13.
//
//

#import "SequencerPopoverHandler.h"

@implementation SequencerPopoverHandler

+ (void) popoverNode:(CCNode*) node property: (NSString*) prop overView:(NSView*) parent kfBounds:(NSRect) kfBounds
{
    NSViewController* vc = [[[NSViewController alloc] initWithNibName:@"SequencerPopoverView" bundle:[NSBundle mainBundle]] autorelease];
    
    NSPopover* popover = [[[NSPopover alloc] init] autorelease];
    //popover.appearance = NSPopoverAppearanceHUD;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = NSMakeSize(100, 100);
    popover.contentViewController = vc;
    popover.animates = YES;
    
    [popover showRelativeToRect:kfBounds ofView:parent preferredEdge:NSMaxYEdge];
}

@end
