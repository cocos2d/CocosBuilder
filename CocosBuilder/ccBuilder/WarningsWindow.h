//
//  WarningsWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class CCBWarnings;
@interface WarningsWindow : NSWindowController <NSTableViewDelegate>
{
    CCBWarnings* warnings;
    //IBOutlet NSTableView* tableView;
}

@property (nonatomic,assign) CCBWarnings* warnings;
@end
