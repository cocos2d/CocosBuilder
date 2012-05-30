//
//  MainWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"

@implementation MainWindow


-(void)disableUpdatesUntilFlush
{
    if(!needsEnableUpdate)
        NSDisableScreenUpdates();
    needsEnableUpdate = YES;
}

-(void)flushWindow
{
    [super flushWindow];
    if(needsEnableUpdate)
    {
        needsEnableUpdate = NO;
        NSEnableScreenUpdates();
    }
}

@end
