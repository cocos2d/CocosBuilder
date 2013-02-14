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
#import "SequencerKeyframe.h"
#import "SequencerPopoverBlock.h"
#import "SequencerPopoverSound.h"

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
    
    // Create a inspector value and view
    NSViewController* vc = [[[NSViewController alloc] initWithNibName:@"SequencerPopoverView" bundle:[NSBundle mainBundle]] autorelease];
    
    NSString* inspectorNibName = [NSString stringWithFormat:@"InspectorPopover%@",type];
    
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:node andPropertyName:prop andDisplayName:@"Position" andExtra:NULL];
    inspectorValue.inPopoverWindow = YES;
    
    [NSBundle loadNibNamed:inspectorNibName owner:inspectorValue];
    NSView* view = inspectorValue.view;
    [view setBoundsOrigin:NSMakePoint(0, 0)];
    
    [vc.view setFrameSize:view.bounds.size];
    [vc.view addSubview:view];
    
    [inspectorValue willBeAdded];
    
    // Open the popover
    NSPopover* popover = [[[NSPopover alloc] init] autorelease];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = view.bounds.size;
    popover.contentViewController = vc;
    popover.animates = YES;
    
    [popover showRelativeToRect:kfBounds ofView:parent preferredEdge:NSMaxYEdge];
}

+ (void) popoverChannelKeyframes:(NSArray*)kfs kfBounds:(NSRect)kfBounds overView:(NSView*) parent
{
    NSViewController* vc = [[[NSViewController alloc] initWithNibName:@"SequencerPopoverView" bundle:[NSBundle mainBundle]] autorelease];
    
    float w = 0;
    float h = 0;
    
    for (SequencerKeyframe* kf in kfs)
    {
        if (kf.type == kCCBKeyframeTypeCallbacks)
        {
            SequencerPopoverBlock* owner = [[[SequencerPopoverBlock alloc] init] autorelease];
            owner.keyframe = kf;
            [NSBundle loadNibNamed:@"SequencerPopoverBlock" owner:owner];
            NSView* view = owner.view;
            
            [vc.view setFrameSize:NSMakeSize(view.bounds.size.width, view.bounds.size.height*kfs.count)];
            
            [vc.view addSubview:view];
            
            [view setFrameOrigin:NSMakePoint(0, h)];
            
            w = view.bounds.size.width;
            h += view.bounds.size.height;
        }
        else if (kf.type == kCCBKeyframeTypeSoundEffects)
        {
            SequencerPopoverSound* owner = [[[SequencerPopoverSound alloc] init] autorelease];
            owner.keyframe = kf;
            [NSBundle loadNibNamed:@"SequencerPopoverSound" owner:owner];
            NSView* view = owner.view;
            
            [vc.view setFrameSize:NSMakeSize(view.bounds.size.width, view.bounds.size.height*kfs.count)];
            
            [owner willBeAdded];
            
            [vc.view addSubview:view];
            
            [view setFrameOrigin:NSMakePoint(0, h)];
            
            w = view.bounds.size.width;
            h += view.bounds.size.height;
        }
    }
    
    // Open the popover
    NSPopover* popover = [[[NSPopover alloc] init] autorelease];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = NSMakeSize(w, h);
    popover.contentViewController = vc;
    popover.animates = YES;
    
    [popover showRelativeToRect:kfBounds ofView:parent preferredEdge:NSMaxYEdge];
}

@end
