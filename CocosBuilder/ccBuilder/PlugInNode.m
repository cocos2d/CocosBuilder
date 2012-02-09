//
//  PlugInNode.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInNode.h"

@implementation PlugInNode

@synthesize nodeClassName;

- (id) initWithBundle:(NSBundle*) b
{
    self = [super init];
    if (!self) return NULL;
    
    bundle = b;
    [bundle retain];
    
    // Load class and make an instance of it
    Class class = [bundle principalClass];
    instance = [[class alloc] init];
    
    nodeClassName = [instance nodeClassName];
    [nodeClassName retain];
    
    // Load properties
    NSURL* propsURL = [bundle URLForResource:@"CCBPProperties" withExtension:@"plist"];
    NSDictionary* props = [NSDictionary dictionaryWithContentsOfURL:propsURL];
    
    NSLog(@"Props: %@ URL: %@", props, propsURL);
    
    return self;
}

- (void) dealloc
{
    [nodeClassName release];
    [bundle release];
    [instance release];
    [super dealloc];
}

@end
