//
//  CCBPLabelTTF.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPLabelTTF.h"

@implementation CCBPLabelTTF

- (void) setAlignment:(int)alignment
{
    self.horizontalAlignment = alignment;
}

- (int) alignment
{
    return self.horizontalAlignment;
}

@end
