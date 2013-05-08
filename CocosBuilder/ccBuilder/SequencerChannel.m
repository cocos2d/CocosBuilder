//
//  SequencerChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerChannel.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerCallbackChannel.h"
#import "SequencerSoundChannel.h"
#import "CocosBuilderAppDelegate.h"

@implementation SequencerChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Channel";
    
    self.seqNodeProp = [[[SequencerNodeProperty alloc] initWithChannel:self] autorelease];
    
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [self init];
    if (!self) return NULL;
    
    if (!ser) return self;
    
    self.seqNodeProp = [[[SequencerNodeProperty alloc] initWithSerialization:ser] autorelease];
    
    return self;
}

- (id) serialize
{
    return [self.seqNodeProp serialization];
}

- (int) keyframeType
{
    if ([self isKindOfClass:[SequencerCallbackChannel class]]) return kCCBKeyframeTypeCallbacks;
    if ([self isKindOfClass:[SequencerSoundChannel class]]) return kCCBKeyframeTypeSoundEffects;
    
    NSAssert(NO, @"Unknown channel type");
    return -1;
}

- (SequencerKeyframe*) defaultKeyframe
{
    // Abstract method
    return NULL;
}

- (void) addDefaultKeyframeAtTime:(float)t
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*addchannelkeyframe"];
    
    SequencerKeyframe* kf = [self defaultKeyframe];
    
    [self.seqNodeProp setKeyframe:kf];
    
    kf.time = t;
}

- (NSArray*) keyframesAtTime:(float)t
{
    NSMutableArray* kfs = [NSMutableArray array];
    for (SequencerKeyframe* kf in self.seqNodeProp.keyframes)
    {
        if (kf.time == t)
        {
            [kfs addObject:kf];
        }
    }
    return kfs;
}

- (id) copyWithZone:(NSZone*)zone
{
    SequencerChannel* copy = [[[self class] alloc] init];
    
    copy.displayName = self.displayName;
    copy.seqNodeProp = [[self.seqNodeProp copy] autorelease];
    
    return copy;
}

- (void) dealloc
{
    self.displayName = NULL;
    self.seqNodeProp = NULL;
    [super dealloc];
}

@end
