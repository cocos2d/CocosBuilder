//
//  SequencerPopoverHandler.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/12/13.
//
//

#import "SequencerPopoverHandler.h"
#import "InspectorValue.h"
#import "PlugInNode.h"
#import "NodeInfo.h"

@implementation SequencerPopoverHandler

+ (void) popoverNode:(CCNode*) node property: (NSString*) prop overView:(NSView*) parent kfBounds:(NSRect) kfBounds
{
    // Get type of property, return if it cannot be found
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    if (!plugIn) return;
    
    NSString* type = NULL;
    
    NSArray* propInfos = plugIn.nodeProperties;
    for (int i = 0; i < [propInfos count]; i++)
    {
        NSDictionary* propInfo = [propInfos objectAtIndex:i];
        NSString* propType = [propInfo objectForKey:@"type"];
        NSString* propName = [propInfo objectForKey:@"name"];
        
        if ([propName isEqualToString:prop])
        {
            type = propType;
        }
    }
    if (!type) return;
    
    NSViewController* vc = [[[NSViewController alloc] initWithNibName:@"SequencerPopoverView" bundle:[NSBundle mainBundle]] autorelease];
    
    NSString* inspectorNibName = [NSString stringWithFormat:@"InspectorPopover%@",type];
    
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:node andPropertyName:prop andDisplayName:@"Position" andExtra:NULL];
    inspectorValue.inPopoverWindow = YES;
    
    [NSBundle loadNibNamed:inspectorNibName owner:inspectorValue];
    NSView* view = inspectorValue.view;
    [view setBoundsOrigin:NSMakePoint(0, 0)];
    
    [vc.view setFrameSize:view.bounds.size];
    [vc.view addSubview:view];
    
    NSPopover* popover = [[[NSPopover alloc] init] autorelease];
    //popover.appearance = NSPopoverAppearanceHUD;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = view.bounds.size;
    popover.contentViewController = vc;
    popover.animates = YES;
    
    [popover showRelativeToRect:kfBounds ofView:parent preferredEdge:NSMaxYEdge];
}

@end
