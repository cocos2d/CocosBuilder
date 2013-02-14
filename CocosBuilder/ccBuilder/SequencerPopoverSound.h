//
//  SequencerPopoverSound.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/13.
//
//

#import <Foundation/Foundation.h>

@class SequencerKeyframe;

@interface SequencerPopoverSound : NSObject
{
    IBOutlet NSView* view;
    
    IBOutlet NSPopUpButton* popup;
}

@property (nonatomic,readonly) IBOutlet NSView* view;
@property (nonatomic,assign) SequencerKeyframe* keyframe;

@property (nonatomic,assign) float pitch;
@property (nonatomic,assign) float pan;
@property (nonatomic,assign) float gain;

- (void) willBeAdded;

@end
