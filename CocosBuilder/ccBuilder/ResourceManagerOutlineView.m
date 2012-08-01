//
//  ResourceManagerOutlineView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerOutlineView.h"

@implementation ResourceManagerOutlineView

- (NSMenu*) menuForEvent:(NSEvent *)evt
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    
    NSLog(@"menuForRow: %d", row);
    
    return NULL;
}

@end
