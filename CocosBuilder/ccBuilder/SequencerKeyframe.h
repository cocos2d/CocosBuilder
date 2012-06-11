//
//  SequencerKeyframe.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencerKeyframe : NSObject
{
    float time;
    BOOL selected;
}

@property (nonatomic,assign) float time;
@property (nonatomic,assign) BOOL selected;

@end
