//
//  Inspector.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@implementation InspectorValue

@synthesize displayName,view;

+ (id) inspectorWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn
{
    return [[[self alloc] initWithSelection:s andPropertyName:pn andDisplayName:dn] autorelease];
}

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn
{
    self = [super init];
    if (!self) return NULL;
    
    propertyName = [pn retain];
    displayName = [dn retain];
    selection = [s retain];
    
    return self;
}

- (id) propertyForSelection
{
    return [selection valueForKey:propertyName];
}

- (void) setPropertyForSelection:(id)value
{
    [selection setValue:value forKey:propertyName];
}

- (void)dealloc
{
    NSLog(@"DEALLOC");
    
    [selection release];
    [propertyName release];
    [displayName release];
    
    [super dealloc];
}

@end
