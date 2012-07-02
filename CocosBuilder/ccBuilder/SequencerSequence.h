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
    
    NSString* name;
    int sequenceId;
}

@property (nonatomic,assign) float timelineScale;
@property (nonatomic,assign) float timelineOffset;
@property (nonatomic,assign) float timelineLength;
@property (nonatomic,assign) float timelinePosition;
@property (nonatomic,assign) float timelineResolution;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) int sequenceId;

@property (nonatomic,readonly) NSString* currentDisplayTime;
@property (nonatomic,readonly) NSString* lengthDisplayTime;

// Convert between actual time and position in sequence view
- (float) timeToPosition:(float)time;
- (float) positionToTime:(float)pos;

- (void) stepForward:(int)numSteps;
- (void) stepBack:(int)numSteps;

- (id) initWithSerialization:(id)ser;
- (id) serialize;

@end
