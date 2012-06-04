//
//  SequencerSequence.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SequencerSequence : NSObject
{
    float timelineScale;
    float timelineOffset;
    float timelineLength;
    float timelinePosition;
    
    float timelineResolution;
}

@property (nonatomic,assign) float timelineScale;
@property (nonatomic,assign) float timelineOffset;
@property (nonatomic,assign) float timelineLength;
@property (nonatomic,assign) float timelinePosition;

// Convert between actual time and position in sequence view
- (float) timeToPosition:(float)time;
- (float) positionToTime:(float)pos;
- (NSString*) currentDisplayTime;

@end
