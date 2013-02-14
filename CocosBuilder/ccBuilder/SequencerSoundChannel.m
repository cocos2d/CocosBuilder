//
//  SequencerSoundChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerSoundChannel.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"

@implementation SequencerSoundChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Sound effects";
    
    return self;
}

- (SequencerKeyframe*) defaultKeyframe
{
    SequencerKeyframe* kf = [[[SequencerKeyframe alloc] init] autorelease];
    
    kf.value = [NSArray arrayWithObjects:
                @"",
                [NSNumber numberWithFloat:1],
                [NSNumber numberWithFloat:0],
                [NSNumber numberWithFloat:1],
                nil];
    kf.type = kCCBKeyframeTypeSoundEffects;
    kf.name = NULL;
    kf.easing = [[[SequencerKeyframeEasing alloc] init] autorelease];
    kf.easing.type = kCCBKeyframeEasingInstant;
    
    return kf;
}

@end
