//
//  SequencerPopoverBlock.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/13.
//
//

#import "SequencerPopoverBlock.h"
#import "SequencerKeyframe.h"
#import "CocosBuilderAppDelegate.h"

@implementation SequencerPopoverBlock

@synthesize view;

- (void) setSelector:(NSString *)selector
{
    if (!selector) selector = @"";
    
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoverblock"];
    
    NSNumber* t = [_keyframe.value objectAtIndex:1];
    
    _keyframe.value = [NSArray arrayWithObjects:selector, t, nil];
}

- (NSString*) selector
{
    NSString* s = [_keyframe.value objectAtIndex:0];
    if (!s) s = @"";
    return s;
}

- (void) setTarget:(int)t
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*popoverblock"];
    
    NSString* s = [_keyframe.value objectAtIndex:0];
    
    _keyframe.value = [NSArray arrayWithObjects:s, [NSNumber numberWithInt:t], nil];
}

- (int) target
{
    return [[_keyframe.value objectAtIndex:1] intValue];
}

@end
