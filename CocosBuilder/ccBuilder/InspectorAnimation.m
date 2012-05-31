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

#import "InspectorAnimation.h"
#import "CCBGlobals.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "AnimationPropertySetter.h"
#import "CCNode+NodeInfo.h"

@implementation InspectorAnimation

- (void) willBeAdded
{
    // Setup menu
    NSString* animName = [selection extraPropForKey:propertyName];
    NSString* animFile = [selection extraPropForKey:[NSString stringWithFormat:@"%@Animation", propertyName]];
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeAnimation allowSpriteFrames:NO selectedFile:animName selectedSheet:animFile target:self];
}

- (void) selectedResource:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the animation name
    NSString* animFile = NULL;
    NSString* animName = NULL;
    
    if ([item isKindOfClass:[RMAnimation class]])
    {
        RMAnimation* anim = item;
        
        animFile = [ResourceManagerUtil relativePathFromAbsolutePath:anim.animationFile];
        animName = anim.animationName;
        
        [ResourceManagerUtil setTitle:[NSString stringWithFormat:@"%@/%@",animFile,animName] forPopup:popup];
    }
    
    if (animFile && animName)
    {
        [selection setExtraProp:animName forKey:propertyName];
        [selection setExtraProp:animFile forKey:[NSString stringWithFormat:@"%@Animation", propertyName]];
        
        [AnimationPropertySetter setAnimationForNode:selection andProperty:propertyName withName:animName andFile:animFile];
    }
    
    [self updateAffectedProperties];
}

@end
