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
    
    self.displayName = @"Sounds";
    
    return self;
}

- (SequencerKeyframe*) defaultKeyframe
{
    SequencerKeyframe* kf = [[[SequencerKeyframe alloc] init] autorelease];
    
    kf.value = [NSDictionary dictionary];
    kf.type = kCCBKeyframeTypeCallbacks;
    kf.name = NULL;
    kf.easing = [[[SequencerKeyframeEasing alloc] init] autorelease];
    kf.easing.type = kCCBKeyframeEasingInstant;
    
    return kf;
}

@end
