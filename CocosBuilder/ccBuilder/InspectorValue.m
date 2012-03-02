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
#import "NodeInfo.h"
#import "PlugInNode.h"

@implementation InspectorValue

@synthesize displayName, view, extra, readOnly, affectsProperties;

+ (id) inspectorOfType:(NSString*) t withSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e
{
    NSString* inspectorClassName = [NSString stringWithFormat:@"Inspector%@",t];
    
    return [[[NSClassFromString(inspectorClassName) alloc] initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e] autorelease];
}

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e;
{
    self = [super init];
    if (!self) return NULL;
    
    propertyName = [pn retain];
    displayName = [dn retain];
    selection = [s retain];
    extra = [e retain];
    
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
    NodeInfo* nodeInfo = selection.userData;
    PlugInNode* plugIn = nodeInfo.plugIn;
    if ([plugIn dontSetInEditorProperty:propertyName])
    {
        return [nodeInfo.extraProps objectForKey:propertyName];
    }
    else
    {
        return [selection valueForKey:propertyName];
    }
    
}

- (void) setPropertyForSelection:(id)value
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    NodeInfo* nodeInfo = selection.userData;
    PlugInNode* plugIn = nodeInfo.plugIn;
    if ([plugIn dontSetInEditorProperty:propertyName])
    {
        // Set the property in the extra props dict
        [nodeInfo.extraProps setObject:value forKey:propertyName];
    }
    else
    {
        [selection setValue:value forKey:propertyName];
    }
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

- (id) propertyForSelectionVar
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"Var"]];
}

- (void) setPropertyForSelectionVar:(id)value
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"Var"]];
    
    [self updateAffectedProperties];
}

- (void)dealloc
{
    self.affectsProperties = NULL;
    [selection release];
    [propertyName release];
    [displayName release];
    
    [super dealloc];
}

@end
