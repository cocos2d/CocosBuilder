//
//  InspectorBlockCCControl.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"
#import "CCControl.h"

@interface InspectorBlockCCControl : InspectorValue
{
    IBOutlet NSButton* btnDown;
    IBOutlet NSButton* btnDragInside;
    IBOutlet NSButton* btnDragOutside;
    IBOutlet NSButton* btnDragEnter;
    IBOutlet NSButton* btnDragExit;
    IBOutlet NSButton* btnUpInside;
    IBOutlet NSButton* btnUpOutside;
    IBOutlet NSButton* btnCancel;
    IBOutlet NSButton* btnValueChanged;
    
    NSMutableDictionary* btns;
    
    CCControlEvent selectedEvents;
}


@property (nonatomic,assign) NSString* selector;
@property (nonatomic,assign) int target;

@end
