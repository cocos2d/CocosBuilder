//
//  MainWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface MainWindow : NSWindow
{
    BOOL needsEnableUpdate;
}

-(void)disableUpdatesUntilFlush;

@end
