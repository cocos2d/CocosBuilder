//
//  SequencerHandler.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerHandler.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "PositionPropertySetter.h"

@implementation SequencerHandler

- (id) initWithOutlineView:(NSOutlineView*)view
{
    self = [super init];
    if (!self) return NULL;
    
    appDelegate = [[CCBGlobals globals] appDelegate];
    outlineHierarchy = view;
    
    [outlineHierarchy setDataSource:self];
    [outlineHierarchy setDelegate:self];
    [outlineHierarchy reloadData];
    
    [outlineHierarchy registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.node", @"com.cocosbuilder.texture", @"com.cocosbuilder.template", NULL]];
    
    return self;
}

- (void) updateOutlineViewSelection
{
    if (!appDelegate.selectedNode)
    {
        [outlineHierarchy selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        return;
    }
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* node = appDelegate.selectedNode;
    NSMutableArray* nodesToExpand = [NSMutableArray array];
    while (node != g.rootNode && node != NULL)
    {
        [nodesToExpand insertObject:node atIndex:0];
        node = node.parent;
    }
    for (int i = 0; i < [nodesToExpand count]; i++)
    {
        node = [nodesToExpand objectAtIndex:i];
        [outlineHierarchy expandItem:node.parent];
    }
    
    int row = (int)[outlineHierarchy rowForItem:appDelegate.selectedNode];
    [outlineHierarchy selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if ([[CCBGlobals globals] rootNode] == NULL) return 0;
    if (item == nil) return 1;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    
    return [arr count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil) return YES;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    NodeInfo* info = node.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    if ([arr count] == 0) return NO;
    if (!plugIn.canHaveChildren) return NO;
    
    return YES;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    CCBGlobals* g= [CCBGlobals globals];
    
    if (item == nil) return g.rootNode;
    
    CCNode* node = (CCNode*)item;
    CCArray* arr = [node children];
    return [arr objectAtIndex:index];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    appDelegate.selectedNode = [outlineHierarchy itemAtRow:[outlineHierarchy selectedRow]];
    [appDelegate updateInspectorFromSelection];
    CCBGlobals* g = [CCBGlobals globals];
    [g.cocosScene setSelectedNode:appDelegate.selectedNode];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithBool:NO] forKey:@"isExpanded" andNode:node];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    CCNode* node = [[notification userInfo] objectForKey:@"NSObject"];
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    [cs setExtraProp:[NSNumber numberWithBool:YES] forKey:@"isExpanded" andNode:node];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if (item == nil) return @"Root";
    
    if ([tableColumn.identifier isEqualToString:@"sequencer"])
    {
        return @"";
    }
    
    CCNode* node = item;
    NodeInfo* info = node.userObject;
    
    // Get class name
    NSString* className = @"";
    NSString* customClass = [cs extraPropForKey:@"customClass" andNode:item];
    if (customClass && ![customClass isEqualToString:@""]) className = customClass;
    else className = info.plugIn.nodeClassName;
    
    // Assignment name
    NSString* assignmentName = [cs extraPropForKey:@"memberVarAssignmentName" andNode:item];
    if (assignmentName && ![assignmentName isEqualToString:@""]) return [NSString stringWithFormat:@"%@ (%@)",className,assignmentName];
    
    if ([item isKindOfClass:[CCMenuItemImage class]])
    {
        NSString* textureName = [cs extraPropForKey:@"spriteFileNormal" andNode:item];
        if (textureName && ![textureName isEqualToString:@""])
        {
            return [NSString stringWithFormat:@"CCMenuItemImage (%@)", textureName];
        }
    }
    
    // Fallback, just use the class name
    return className;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    CCBGlobals* g = [CCBGlobals globals];
    
    CCNode* draggedNode = [items objectAtIndex:0];
    if (draggedNode == g.rootNode) return NO;
    
    NSMutableDictionary* clipDict = [CCBWriterInternal dictionaryFromCCObject:draggedNode];
    
    [clipDict setObject:[NSNumber numberWithLongLong:(long long)draggedNode] forKey:@"srcNode"];
    NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
    
    [pboard setData:clipData forType:@"com.cocosbuilder.node"];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if (item == NULL) return NSDragOperationNone;
    
    CCBGlobals* g = [CCBGlobals globals];
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* nodeData = [pb dataForType:@"com.cocosbuilder.node"];
    if (nodeData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:nodeData];
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        
        CCNode* node = item;
        CCNode* parent = [node parent];
        while (parent && parent != g.rootNode)
        {
            if (parent == draggedNode) return NSDragOperationNone;
            parent = [parent parent];
        }
        
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationGeneric;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
    NSPasteboard* pb = [info draggingPasteboard];
    
    NSData* clipData = [pb dataForType:@"com.cocosbuilder.node"];
    if (clipData)
    {
        NSMutableDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CCNode* clipNode= [CCBReaderInternal nodeGraphFromDictionary:clipDict parentSize:CGSizeZero];
        if (![appDelegate addCCObject:clipNode toParent:item atIndex:index]) return NO;
        
        // Remove old node
        CCNode* draggedNode = (CCNode*)[[clipDict objectForKey:@"srcNode"] longLongValue];
        [appDelegate deleteNode:draggedNode];
        
        [appDelegate setSelectedNode:clipNode];
        
        [PositionPropertySetter refreshAllPositions];
        
        return YES;
    }
    clipData = [pb dataForType:@"com.cocosbuilder.texture"];
    if (clipData)
    {
        NSDictionary* clipDict = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        [appDelegate dropAddSpriteNamed:[clipDict objectForKey:@"spriteFile"] inSpriteSheet:[clipDict objectForKey:@"spriteSheetFile"] at:ccp(0,0) parent:item];
        
        [PositionPropertySetter refreshAllPositions];
        
        return YES;
    }
    
    return NO;
}

- (void) updateExpandedForNode:(CCNode*)node
{
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    if ([self outlineView:outlineHierarchy isItemExpandable:node])
    {
        bool expanded = [[cs extraPropForKey:@"isExpanded" andNode:node] boolValue];
        if (expanded) [outlineHierarchy expandItem:node];
        else [outlineHierarchy collapseItem:node];
        
        CCArray* childs = [node children];
        for (int i = 0; i < [childs count]; i++)
        {
            CCNode* child = [childs objectAtIndex:i];
            [self updateExpandedForNode:child];
        }
    }
}

@end
