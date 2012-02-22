//
//  InspectorStartStop.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorStartStop.h"

@implementation InspectorStartStop

@synthesize startName,stopName;

- (id) initWithSelection:(CCNode *)s andPropertyName:(NSString *)pn andDisplayName:(NSString *)dn andExtra:(NSString *)e
{
    self = [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
    if (!self) return NULL;
    
    NSArray* bntNames = [displayName componentsSeparatedByString:@"|"];
    self.startName = [bntNames objectAtIndex:0];
    self.stopName = [bntNames objectAtIndex:1];
    
    NSArray* methodNames = [extra componentsSeparatedByString:@"|"];
    startMethod = [[methodNames objectAtIndex:0] retain];
    stopMethod = [[methodNames objectAtIndex:1] retain];
    
    return self;
}

- (IBAction)pressedStart:(id)sender
{
    SEL selector = NSSelectorFromString(startMethod);
    [selection performSelector:selector];
}

- (IBAction)pressedStop:(id)sender
{
    SEL selector = NSSelectorFromString(stopMethod);
    [selection performSelector:selector];
}

- (void) dealloc
{
    [startMethod dealloc];
    [stopMethod dealloc];
    self.startName = NULL;
    self.stopName = NULL;
    [super dealloc];
}

@end
