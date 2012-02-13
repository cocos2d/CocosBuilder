//
//  PlugInNode.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInNode.h"

@implementation PlugInNode

@synthesize nodeClassName, nodeEditorClassName, nodeProperties;

- (id) initWithBundle:(NSBundle*) b
{
    self = [super init];
    if (!self) return NULL;
    
    bundle = b;
    [bundle retain];
    
    // Load properties
    NSURL* propsURL = [bundle URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithContentsOfURL:propsURL];
    
    nodeClassName = [[props objectForKey:@"className"] retain];
    nodeEditorClassName = [[props objectForKey:@"editorClassName"] retain];
    
    nodeProperties = [[props objectForKey:@"properties"] retain];
    
    return self;
}

- (void) dealloc
{
    [nodeProperties release];
    [nodeClassName release];
    [bundle release];
    [super dealloc];
}

@end
