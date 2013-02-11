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

#import <Foundation/Foundation.h>

#define TIMELINE_PAD_PIXELS 5.0f

@class SequencerSettingsWindow;
@class SequencerCallbackChannel;
@class SequencerSoundChannel;

@interface SequencerSequence : NSObject
{
    float timelineScale;
    float timelineOffset;
    float timelineLength;
    float timelinePosition;
    float timelineResolution;
    
    NSString* name;
    int sequenceId;
    int chainedSequenceId;
    
    SequencerCallbackChannel* callbackChannel;
    SequencerSoundChannel* soundChannel;
    
    BOOL autoPlay;
    
    SequencerSettingsWindow* settingsWindow;
}

@property (nonatomic,assign) float timelineScale;
@property (nonatomic,assign) float timelineOffset;
@property (nonatomic,assign) float timelineLength;
@property (nonatomic,assign) float timelinePosition;
@property (nonatomic,assign) float timelineResolution;
@property (nonatomic,copy) NSString* name;
@property (nonatomic,assign) int sequenceId;
@property (nonatomic,assign) int chainedSequenceId;
@property (nonatomic,readonly) SequencerCallbackChannel* callbackChannel;
@property (nonatomic,readonly) SequencerSoundChannel* soundChannel;


@property (nonatomic,readonly) NSString* currentDisplayTime;
@property (nonatomic,readonly) NSString* lengthDisplayTime;

@property (nonatomic,assign) BOOL autoPlay;

@property (nonatomic,assign) SequencerSettingsWindow* settingsWindow;

// Convert between actual time and position in sequence view
- (float) timeToPosition:(float)time;
- (float) positionToTime:(float)pos;

- (void) stepForward:(int)numSteps;
- (void) stepBack:(int)numSteps;

- (id) initWithSerialization:(id)ser;
- (id) serialize;

- (SequencerSequence*) duplicateWithNewId:(int)seqId;

- (float) alignTimeToResolution:(float)time;

@end
