//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBTextFieldCell.h"


@implementation CCBTextFieldCell

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // Returning nil circumvents the standard row highlighting.
    return nil;
}

- (NSColor *)textColor
{
    if([self isHighlighted])
    {
        return [NSColor whiteColor];
    }
    else
    {
        return [NSColor blackColor];
    }
}

@end
