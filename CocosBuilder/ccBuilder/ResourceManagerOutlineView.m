//
//  ResourceManagerOutlineView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerOutlineView.h"
#import "CocosBuilderAppDelegate.h"

@implementation ResourceManagerOutlineView

- (NSMenu*) menuForEvent:(NSEvent *)evt
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    
    NSLog(@"menuForRow: %d", row);
    
    NSMenu* menu = [CocosBuilderAppDelegate appDelegate].menuContextResManager;
    
    // TODO: Update menu
    
    return menu;
}

@end
