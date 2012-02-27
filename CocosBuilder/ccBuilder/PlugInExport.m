//
//  PlugInExport.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlugInExport.h"
#import "CCBX.h"

@implementation PlugInExport

@synthesize extension, pluginName;

- (id) initWithBundle:(NSBundle*) b
{
    self = [super init];
    if (!self) return NULL;
    
    bundle = [b retain];
    
    // Load plug-in properties
    Class exporterClass = [bundle principalClass];
    CCBX* exporter = [[exporterClass alloc] init];
    extension = [[exporter extension] retain];
    
    return self;
}

- (NSData*) exportDocument:(NSDictionary*)doc
{
    Class exporterClass = [bundle principalClass];
    CCBX* exporter = [[exporterClass alloc] init];
    return [exporter exportDocument:doc];
}

- (void) dealloc
{
    self.pluginName = NULL;
    [bundle release];
    [extension release];
    [super dealloc];
}

@end
