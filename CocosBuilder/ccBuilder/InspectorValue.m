//
//  Inspector.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"

@implementation InspectorValue

@synthesize displayName, view, readOnly, affectsProperties;

+ (id) inspectorOfType:(NSString*) t withSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn
{
    NSString* inspectorClassName = [NSString stringWithFormat:@"Inspector%@",t];
    
    return [[[NSClassFromString(inspectorClassName) alloc] initWithSelection:s andPropertyName:pn andDisplayName:dn] autorelease];
}

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn
{
    self = [super init];
    if (!self) return NULL;
    
    propertyName = [pn retain];
    displayName = [dn retain];
    selection = [s retain];
    
    resourceManager = [[CCBGlobals globals] appDelegate];
    
    return self;
}

- (void) refresh
{
}

- (void) updateAffectedProperties
{
    if (affectsProperties)
    {
        for (int i = 0; i < [affectsProperties count]; i++)
        {
            NSString* propName = [affectsProperties objectAtIndex:i];
            CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
            [ad refreshProperty:propName];
        }
    }
}

- (id) propertyForSelection
{
    return [selection valueForKey:propertyName];
}

- (void) setPropertyForSelection:(id)value
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:propertyName];
    [self updateAffectedProperties];
}

- (id) propertyForSelectionX
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"X"]];
}

- (void) setPropertyForSelectionX:(id)value
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"X"]];
    [self updateAffectedProperties];
}

- (id) propertyForSelectionY
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"Y"]];
}

- (void) setPropertyForSelectionY:(id)value
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"Y"]];
    [self updateAffectedProperties];
}

- (void)dealloc
{
    NSLog(@"DEALLOC");
    
    self.affectsProperties = NULL;
    [selection release];
    [propertyName release];
    [displayName release];
    
    [super dealloc];
}

@end
