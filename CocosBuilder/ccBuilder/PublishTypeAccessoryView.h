//
//  PublishTypeAccessoryView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PublishTypeAccessoryView : NSViewController
{
    NSArray* exporterNames;
    int selectedIndex;
    NSSavePanel* savePanel;
}

@property (nonatomic,retain) NSArray* exporterNames;
@property (nonatomic,assign) int selectedIndex;
@property (nonatomic,retain) NSSavePanel* savePanel;

@end
