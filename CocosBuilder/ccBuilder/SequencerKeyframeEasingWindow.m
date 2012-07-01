//
//  SequencerKeyframeEasingWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerKeyframeEasingWindow.h"

@interface SequencerKeyframeEasingWindow ()

@end

@implementation SequencerKeyframeEasingWindow

@synthesize option;
@synthesize optionName;

- (void) dealloc
{
    self.optionName = NULL;
    [super dealloc];
}

@end
