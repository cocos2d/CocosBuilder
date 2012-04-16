//
//  CCBTransparentView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBTransparentView.h"

@implementation CCBTransparentView

- (void)drawRect:(NSRect)rect {
    [[NSColor clearColor] set];
    NSRectFill(rect);
}

@end
