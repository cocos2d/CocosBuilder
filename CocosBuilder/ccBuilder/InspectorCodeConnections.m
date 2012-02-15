//
//  InspectorCodeConnections.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorCodeConnections.h"
#import "CocosScene.h"
#import "CCBGlobals.h"

@implementation InspectorCodeConnections

- (void) setCustomClass:(NSString *)customClass
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:customClass forKey:@"customClass" andNode:selection];
}

- (NSString*) customClass
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"customClass" andNode:selection];
}

- (void) setMemberVarAssignmentName:(NSString *)memberVarAssignmentName
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:memberVarAssignmentName forKey:@"memberVarAssignmentName" andNode:selection];
}

- (NSString*) memberVarAssignmentName
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [cs extraPropForKey:@"memberVarAssignmentName" andNode:selection];
}

- (void) setMemberVarAssignmentType:(int)memberVarAssignmentType
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithInt: memberVarAssignmentType] forKey:@"memberVarAssignmentType" andNode:selection];
}

- (int) memberVarAssignmentType
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    return [[cs extraPropForKey:@"memberVarAssignmentType" andNode:selection] intValue];
}

@end
