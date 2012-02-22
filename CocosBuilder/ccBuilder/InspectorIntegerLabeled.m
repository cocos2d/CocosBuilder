//
//  InspectorIntegerLabeled.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorIntegerLabeled.h"

@implementation InspectorIntegerLabeled

- (id) initWithSelection:(CCNode *)s andPropertyName:(NSString *)pn andDisplayName:(NSString *)dn andExtra:(NSString *)e
{
    self = [super initWithSelection:s andPropertyName:pn andDisplayName:dn andExtra:e];
    if (!self) return NULL;
    
    return self;
}

- (void) awakeFromNib
{
    // Setup menu
    [menu removeAllItems];
    
    NSArray* strComps = [extra componentsSeparatedByString:@"|"];
    
    for (int i = 0; i < [strComps count]/2; i++)
    {
        NSString* title = [strComps objectAtIndex:i*2];
        int tag = [[strComps objectAtIndex:i*2+1] intValue];
        
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""] autorelease];
        [item setTag:tag];
        
        [menu addItem:item];
    }
    
    [popup selectItemWithTag:[[self propertyForSelection] intValue]];
    
    /*
    [self willChangeValueForKey:@"selectedTag"];
    [self didChangeValueForKey:@"selectedTag"];
     */
}

- (void) setSelectedTag:(int)selectedTag
{
    NSLog(@"setSelectedTag: %d", selectedTag);
    
    [self setPropertyForSelection:[NSNumber numberWithInt:selectedTag]];
}

- (int) selectedTag
{
    int st = [[self propertyForSelection] intValue];
    
    NSLog(@"selectedTag=%d",st);
    return st;
}

@end
