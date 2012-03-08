//
//  InspectorAnimation.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorAnimation.h"
#import "CCBGlobals.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "AnimationPropertySetter.h"

@implementation InspectorAnimation

- (void) willBeAdded
{
    // Setup menu
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    NSString* animName = [cs extraPropForKey:propertyName andNode:selection];
    NSString* animFile = [cs extraPropForKey:[NSString stringWithFormat:@"%@Animation", propertyName] andNode:selection];
    
    NSLog(@"willBeAdded animName:%@ animFile%@", animName, animFile);
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeAnimation allowSpriteFrames:NO selectedFile:animName selectedSheet:animFile target:self];
}

- (void) selectedResource:(id)sender
{
    [[[CCBGlobals globals] appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
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
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
        
        [cs setExtraProp:animName forKey:propertyName andNode:selection];
        [cs setExtraProp:animFile forKey:[NSString stringWithFormat:@"%Animation", propertyName] andNode:selection];
        
        [AnimationPropertySetter setAnimationForNode:selection andProperty:propertyName withName:animName andFile:animFile];
    }
    
    [self updateAffectedProperties];
}

@end
