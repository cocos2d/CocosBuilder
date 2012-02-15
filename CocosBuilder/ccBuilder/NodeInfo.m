//
//  NodeInfo.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeInfo.h"
#import "PlugInNode.h"

@implementation NodeInfo

@synthesize plugIn,extraProps;

+ (id) nodeInfoWithPlugIn:(PlugInNode*)pin
{
    NodeInfo* info = [[[NodeInfo alloc] init] autorelease];
    info.plugIn = pin;
    return info;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    extraProps = [[NSMutableDictionary alloc] init];
    
    [extraProps setObject:@"" forKey:@"customClass"];
    [extraProps setObject:[NSNumber numberWithBool:YES] forKey:@"isExpanded"];
    [extraProps setObject:[NSNumber numberWithInt:0] forKey:@"memberVarAssignmentType"];
    [extraProps setObject:@"" forKey:@"memberVarAssignmentName"];
    
    return self;
}

- (void) dealloc
{
    [extraProps release];
    [super dealloc];
}

@end
