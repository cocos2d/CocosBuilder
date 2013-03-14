/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "InspectorValue.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "CCNode+NodeInfo.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "SequencerNodeProperty.h"

@implementation InspectorValue

@synthesize displayName;
@synthesize view;
@synthesize extra;
@synthesize readOnly;
@synthesize affectsProperties;
@synthesize inspectorValueBelow;
@synthesize rootNode;
@synthesize inPopoverWindow;
@synthesize textFieldOriginalValue;

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
    
    resourceManager = [CocosBuilderAppDelegate appDelegate];
    
    return self;
}

- (void) refresh
{
}

- (void) willBeAdded
{
}

- (void) willBeRemoved
{
}

- (void) updateAffectedProperties
{
    if (affectsProperties)
    {
        for (int i = 0; i < [affectsProperties count]; i++)
        {
            NSString* propName = [affectsProperties objectAtIndex:i];
            CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
            [ad refreshProperty:propName];
        }
    }
    
    if (inPopoverWindow)
    {
        [[CocosBuilderAppDelegate appDelegate] updateInspectorFromSelection];
    }
}

- (id) propertyForSelection
{
    NodeInfo* nodeInfo = selection.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    if ([plugIn dontSetInEditorProperty:propertyName] ||
        [[selection extraPropForKey:@"customClass"] isEqualTo:propertyName])
    {
        return [nodeInfo.extraProps objectForKey:propertyName];
    }
    else
    {
        return [selection valueForKey:propertyName];
    }
    
}

- (void) updateAnimateablePropertyValue:(id)value
{
    NodeInfo* nodeInfo = selection.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    
    if ([plugIn isAnimatableProperty:propertyName node:selection])
    {
        SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
        int seqId = seq.sequenceId;
        SequencerNodeProperty* seqNodeProp = [selection sequenceNodeProperty:propertyName sequenceId:seqId];
        
        if (seqNodeProp)
        {
            SequencerKeyframe* keyframe = [seqNodeProp keyframeAtTime:seq.timelinePosition];
            if (keyframe)
            {
                keyframe.value = value;
            }
            
            [[SequencerHandler sharedHandler] redrawTimeline];
        }
        else
        {
            [nodeInfo.baseValues setObject:value forKey:propertyName];
        }
    }
}

- (void) setPropertyForSelection:(id)value
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    NodeInfo* nodeInfo = selection.userObject;
    PlugInNode* plugIn = nodeInfo.plugIn;
    if ([plugIn dontSetInEditorProperty:propertyName] || [[selection extraPropForKey:@"customClass"] isEqualTo:propertyName])
    {
        // Set the property in the extra props dict
        [nodeInfo.extraProps setObject:value forKey:propertyName];
    }
    else
    {
        [selection setValue:value forKey:propertyName];
    }
    
    // Handle animatable properties
    [self updateAnimateablePropertyValue:value];
    
    // Update affected properties
    [self updateAffectedProperties];
}

- (id) propertyForSelectionX
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"X"]];
}

- (void) setPropertyForSelectionX:(id)value
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"X"]];
    [self updateAffectedProperties];
}

- (id) propertyForSelectionY
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"Y"]];
}

- (void) setPropertyForSelectionY:(id)value
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"Y"]];
    [self updateAffectedProperties];
}

- (id) propertyForSelectionVar
{
    return [selection valueForKey:[propertyName stringByAppendingString:@"Var"]];
}

- (void) setPropertyForSelectionVar:(id)value
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    [selection setValue:value forKey:[propertyName stringByAppendingString:@"Var"]];
    
    [self updateAffectedProperties];
}

- (void)dealloc
{
    self.affectsProperties = NULL;
    self.textFieldOriginalValue = NULL;
    [selection release];
    [propertyName release];
    [displayName release];
    [inspectorValueBelow release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Disclosure

- (void)hideAllToNextSeparatorWithAboveSeparator:(InspectorValue*)aboveSeparator
{
    [self.view setHidden:YES];
    return [inspectorValueBelow hideAllToNextSeparatorWithAboveSeparator:aboveSeparator];
}

- (void)showAllToNextSeparatorWithAbove:(InspectorValue*)above
{
    NSRect frame = self.view.frame;
    frame.origin.y = above.view.frame.origin.y + above.view.frame.size.height;
    self.view.frame = frame;
    [self.view setHidden:NO];
    [inspectorValueBelow showAllToNextSeparatorWithAbove:self];
}

- (void)moveToMeetAbove:(InspectorValue*)above
{
    if (!self.view.isHidden) {
        NSRect frame = self.view.frame;
        frame.origin.y = above.view.frame.origin.y + above.view.frame.size.height;
        self.view.frame = frame;
        [inspectorValueBelow moveToMeetAbove:self];
    }
    else {
        [inspectorValueBelow moveToMeetAbove:above];
    }
}

- (BOOL)isSeparator
{
    return NO;
}

- (BOOL)setSuperviewFrameHeight
{
    if (![inspectorValueBelow setSuperviewFrameHeight]) {
        if (self.view.isHidden == NO) {
            NSView* superView = self.view.superview;
            [superView setFrameSize:NSMakeSize(superView.frame.size.width, self.view.frame.origin.y+self.view.frame.size.height)];
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark Error handling for validation of text fields

- (BOOL) control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    NSTextField* tf = (NSTextField*)control;
    
    self.textFieldOriginalValue = [tf stringValue];
    
    return YES;
}

- (BOOL) control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error
{
    NSBeep();
    
    NSTextField* tf = (NSTextField*)control;
    [tf setStringValue:self.textFieldOriginalValue];
    
    return YES;
}

@end
