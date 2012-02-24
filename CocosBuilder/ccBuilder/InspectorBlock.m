//
//  InspectorBlock.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorBlock.h"
#import "CCBGlobals.h"

@implementation InspectorBlock

- (void) setSelector:(NSString *)selector
{
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

@end
