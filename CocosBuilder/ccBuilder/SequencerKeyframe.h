//
//  SequencerKeyframe.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SequencerNodeProperty;

enum
{
    kCCBKeyframeTypeUndefined,
    kCCBKeyframeTypeVisible,
    kCCBKeyframeTypeDegrees,
    kCCBKeyframeTypePosition,
};

@interface SequencerKeyframe : NSObject
{
    id value;
    int type;
    NSString* name;
    
    float time;
    float timeAtDragStart;
    BOOL selected;
    
    SequencerNodeProperty* parent;
}

@property (nonatomic,retain) id value;
@property (nonatomic,assign) int type;
@property (nonatomic,retain) NSString* name;

@property (nonatomic,assign) float time;
@property (nonatomic,assign) float timeAtDragStart;
@property (nonatomic,assign) BOOL selected;

@property (nonatomic,assign) SequencerNodeProperty* parent;

- (id) initWithSerialization:(id)ser;
- (id) serialization;

+ (int) keyframeTypeFromPropertyType:(NSString*)type;

@end
