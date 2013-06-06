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
