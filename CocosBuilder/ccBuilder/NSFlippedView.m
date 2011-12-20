//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "NSFlippedView.h"


@implementation NSFlippedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
 */

- (BOOL) isFlipped
{
    return YES;
}

@end
