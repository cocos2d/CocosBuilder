//
//  HelpWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface HelpWindow : NSWindowController <NSTableViewDelegate>
{
    IBOutlet NSTableView* tableView;
    IBOutlet WebView* webView;
    NSMutableArray* mdFiles;
}

@property (nonatomic,readonly) NSMutableArray* mdFiles;

@end
