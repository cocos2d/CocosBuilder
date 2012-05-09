//
//  ProjectSettings.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectSettings.h"

@implementation ProjectSettings

@synthesize projectPath;
@synthesize resourcePaths;
@synthesize publishDirectory;
@synthesize flattenPaths;
@synthesize publishToZipFile;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    resourcePaths = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc
{
    self.resourcePaths = NULL;
    self.projectPath = NULL;
    self.publishDirectory = NULL;
    [super dealloc];
}

@end
