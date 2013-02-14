//
//  SequencerPopoverSound.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/13.
//
//

#import "SequencerPopoverSound.h"
#import "SequencerKeyframe.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"

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
    NSLog(@"Selected resource");
    
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
    _keyframe.value = [self replaceObjectAtIndex:1 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pitch]];
}

- (float) pan
{
    return [[_keyframe.value objectAtIndex:2] floatValue];
}

- (void) setPan:(float)pan
{
    _keyframe.value = [self replaceObjectAtIndex:2 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:pan]];
}

- (float) gain
{
    return [[_keyframe.value objectAtIndex:3] floatValue];
}

- (void) setGain:(float)gain
{
    _keyframe.value = [self replaceObjectAtIndex:3 inArray:_keyframe.value withObject:[NSNumber numberWithFloat:gain]];
}

@end
