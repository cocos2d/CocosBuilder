//
//  SequencerChannel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/7/13.
//
//

#import "SequencerChannel.h"

@implementation SequencerChannel

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.displayName = @"Channel";
    
    return self;
}

- (void) dealloc
{
    self.displayName = NULL;
    [super dealloc];
}

@end
