//
//  CCNode+NodeInfo.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCNode+NodeInfo.h"
#import "NodeInfo.h"
#import "PlugInNode.h"

@implementation CCNode (NodeInfo)

- (void) setExtraProp:(id)prop forKey:(NSString *)key
{
    NodeInfo* info = self.userObject;
    [info.extraProps setObject:prop forKey:key];
}

- (id) extraPropForKey:(NSString *)key
{
    NodeInfo* info = self.userObject;
    return [info.extraProps objectForKey:key];
}

- (void) setSeqExpanded:(BOOL)seqExpanded
{
    [self setExtraProp:[NSNumber numberWithBool:seqExpanded] forKey:@"seqExpanded"];
}

- (BOOL) seqExpanded
{
    return [[self extraPropForKey:@"seqExpanded"] boolValue];
}

- (PlugInNode*) plugIn
{
    NodeInfo* info = self.userObject;
    return info.plugIn;
}

@end
