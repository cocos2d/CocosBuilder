//
//  SequencerCallbackChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerCallbackChannel.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"

@implementation SequencerCallbackChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Callbacks";
    
    return self;
}

- (SequencerKeyframe*) defaultKeyframe
{
    SequencerKeyframe* kf = [[[SequencerKeyframe alloc] init] autorelease];
    
    kf.value = [NSArray arrayWithObjects:@"", [NSNumber numberWithInt:0], nil];
    kf.type = kCCBKeyframeTypeCallbacks;
    kf.name = NULL;
    kf.easing = [[[SequencerKeyframeEasing alloc] init] autorelease];
    kf.easing.type = kCCBKeyframeEasingInstant;
    
    return kf;
}

@end
