//
//  SequencerSoundChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerSoundChannel.h"

@implementation SequencerSoundChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Sounds";
    
    return self;
}

@end
