//
//  InspectorBlockCCControl.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorBlockCCControl.h"
#import "CCBGlobals.h"

@implementation InspectorBlockCCControl

- (void) willBeAdded
{
    btns = [[NSMutableDictionary alloc] init];
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    selectedEvents = [[cs extraPropForKey:[NSString stringWithFormat:@"%@CtrlEvts", propertyName] andNode:selection] intValue];
    
    [btns setObject:btnDown forKey:[NSNumber numberWithInt:CCControlEventTouchDown]];
    [btns setObject:btnDragInside forKey:[NSNumber numberWithInt:CCControlEventTouchDragInside]];
    [btns setObject:btnDragOutside forKey:[NSNumber numberWithInt:CCControlEventTouchDragOutside]];
    [btns setObject:btnDragEnter forKey:[NSNumber numberWithInt:CCControlEventTouchDragEnter]];
    [btns setObject:btnDragExit forKey:[NSNumber numberWithInt:CCControlEventTouchDragExit]];
    [btns setObject:btnUpInside forKey:[NSNumber numberWithInt:CCControlEventTouchUpInside]];
    [btns setObject:btnUpOutside forKey:[NSNumber numberWithInt:CCControlEventTouchUpOutside]];
    [btns setObject:btnCancel forKey:[NSNumber numberWithInt:CCControlEventTouchCancel]];
    [btns setObject:btnValueChanged forKey:[NSNumber numberWithInt:CCControlEventValueChanged]];
    
    for (NSNumber* evtVal in btns)
    {
        int evt = [evtVal intValue];
        NSButton* btn = [btns objectForKey:evtVal];
        
        if (selectedEvents & evt)
        {
            [btn setState:NSOnState];
        }
        else
        {
            [btn setState:NSOffState];
        }
        
        [btn setTarget:self];
        [btn setAction:@selector(toggledCheck:)];
        [btn setTag:evt];
    }
}

- (void) dealloc
{
    [btns release];
    [super dealloc];
}

- (void) setSelector:(NSString *)selector
{
    if (!selector) selector = @"";
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:selector forKey:propertyName andNode:selection];
}

- (NSString*) selector
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    NSString* sel = [cs extraPropForKey:propertyName andNode:selection];
    if (!sel) sel = @"";
    return sel;
}

- (void) setTarget:(int)target
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:target] forKey:[NSString stringWithFormat:@"%@Target", propertyName] andNode:selection];
}

- (int) target
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:[NSString stringWithFormat:@"%@Target", propertyName] andNode:selection] intValue];
}

- (void) toggledCheck:(id)sender
{
    NSButton* btn = sender;
    
    CCControlEvent evt = [btn tag];
    
    if ([btn state] == NSOnState)
    {
        selectedEvents |= evt;
    }
    else
    {
        selectedEvents &= ~evt;
    }
    
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt:selectedEvents] forKey:[NSString stringWithFormat:@"%@CtrlEvts", propertyName] andNode:selection];
}

@end
