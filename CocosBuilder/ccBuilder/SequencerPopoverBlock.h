//
//  SequencerPopoverBlock.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/13/13.
//
//

#import <Foundation/Foundation.h>

@class SequencerKeyframe;

@interface SequencerPopoverBlock : NSObject
{
    IBOutlet NSView* view;
}

@property (nonatomic,readonly) IBOutlet NSView* view;

@property (nonatomic,assign) SequencerKeyframe* keyframe;
@property (nonatomic,assign) NSString* selector;
@property (nonatomic,assign) int target;

@end
