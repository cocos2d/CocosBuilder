//
//  CCBWarnings.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBWarnings.h"

@implementation CCBWarning
@synthesize description;
@synthesize fatal;

- (void) dealloc
{
    self.description = NULL;
    [super dealloc];
}

@end


@implementation CCBWarnings

@synthesize warnings;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    warnings = [[NSMutableArray array] retain];
    
    return self;
}

- (void) addWarningWithDescription:(NSString*)description isFatal:(BOOL)fatal
{
    CCBWarning* warning = [[[CCBWarning alloc] init] autorelease];
    warning.description = description;
    warning.fatal = fatal;
    [self addWarning:warning];
}

- (void) addWarningWithDescription:(NSString*)description
{
    CCBWarning* warning = [[[CCBWarning alloc] init] autorelease];
    warning.description = description;
    [self addWarning:warning];
}

- (void) addWarning:(CCBWarning*)warning
{
    [warnings addObject:warning];
    NSLog(@"CCB WARNING: %@", warning.description);
}

- (void) dealloc
{
    [warnings release];
    [super dealloc];
}

@end
