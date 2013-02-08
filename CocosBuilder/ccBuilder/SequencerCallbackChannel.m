//
//  SequencerCallbackChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerCallbackChannel.h"

@implementation SequencerCallbackChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Callbacks";
    
    return self;
}

@end
