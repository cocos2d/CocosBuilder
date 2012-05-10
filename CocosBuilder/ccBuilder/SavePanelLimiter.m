//
//  SavePanelLimiter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SavePanelLimiter.h"
#import "ResourceManager.h"
#import <AppKit/AppKitErrors.h>

@implementation SavePanelLimiter

- (id) initWithPanel:(NSSavePanel*)savePanel resManager:(ResourceManager*)rm
{
    self = [super init];
    if (!self) return NULL;
    
    resManager = [rm retain];
    [savePanel setDelegate:self];
    
    return self;
}

- (void) dealloc
{
    [resManager release];
    [super dealloc];
}


- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    NSString *path = [url path];
    
    NSArray* activeDirs = resManager.activeDirectories;
    BOOL inProjectPath = NO;
    for (RMDirectory* dir in activeDirs)
    {
        if ([path hasPrefix:dir.dirPath])
        {
            inProjectPath = YES;
            break;
        }
    }
    
    if (!inProjectPath)
    {
        if (outError) *outError = [NSError errorWithDomain:NSCocoaErrorDomain code: NSServiceMiscellaneousError userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You need to save the ccb-file in a directory that is among your projects resource paths. (You can configure the paths in Project Settings).", @"") forKey:NSLocalizedDescriptionKey]];
        return NO;    
    }
    return YES;
}

@end
