//
//  CCBActionManager.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCBSequence;

@interface CCBActionManager : NSObject
{
    NSMutableArray* sequences;
    NSMutableDictionary* nodeSequences;
    int autoPlaySequenceId;
}
@property (nonatomic,readonly) NSMutableArray* sequences;
@property (nonatomic,assign) int autoPlaySequenceId;

- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq;

- (void) runActionsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration;
- (void) runActionsForSequenceNamed:(NSString*)name;

@end
