//
//  SequencerTimelineDrawDelegate.h
//  CocosBuilder
//
//  Created by Aris Tzoumas on 19/10/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol SequencerTimelineDrawDelegate <NSObject>

-(BOOL) canDrawInterpolationForProperty:(NSString*) propName;
-(void) drawInterpolationInRect:(NSRect) rect forProperty:(NSString*) propName withStartValue:(id) startValue endValue:(id) endValue andDuration:(float) duration;
@end
