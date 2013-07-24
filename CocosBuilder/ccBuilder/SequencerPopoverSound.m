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

#import "SequencerPopoverSound.h"
#import "SequencerKeyframe.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"

@implementation SequencerPopoverSound

@synthesize view;

- (NSArray*) replaceObjectAtIndex:(int)idx inArray:(NSArray*)arr withObject:(id)obj
{
    NSMutableArray* newArr = [NSMutableArray arrayWithArray:arr];
    [newArr replaceObjectAtIndex:idx withObject:obj];
    return newArr;
}

- (void) willBeAdded
{
    // Setup menu
    NSString* sound = [_keyframe.value objectAtIndex:0];//[selection extraPropForKey:propertyName];
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeAudio allowSpriteFrames:NO selectedFile:sound selectedSheet:NULL target:self];
}

- (void) selectedResource:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoversound"];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* sound = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeAudio)
        {
            sound = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            [ResourceManagerUtil setTitle:sound forPopup:popup];
            
            if (!sound) sound = @"";
            NSArray* val = _keyframe.value;
            _keyframe.value = [self replaceObjectAtIndex:0 inArray:val withObject:sound];
        }
    }
}

- (float) pitch
{
    return [[_keyframe.value objectAtIndex:1] floatValue];
}

- (void) setPitch:(float)pitch
{
    if (pitch <= 0) return;
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoversound"];
    
    _keyframe.value = [self replaceObjectAtIndex:1 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pitch]];
}

- (float) pan
{
    return [[_keyframe.value objectAtIndex:2] floatValue];
}

- (void) setPan:(float)pan
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoversound"];
    
    _keyframe.value = [self replaceObjectAtIndex:2 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pan]];
}

- (float) gain
{
    return [[_keyframe.value objectAtIndex:3] floatValue];
}

- (void) setGain:(float)gain
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoversound"];
    
    _keyframe.value = [self replaceObjectAtIndex:3 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:gain]];
}

- (void) dealloc
{
    self.textFieldOriginalValue = NULL;
    [super dealloc];
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
