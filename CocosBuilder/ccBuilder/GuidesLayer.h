//
//  GuidesLayer.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#define kCCBGuideNone -1

enum
{
    kCCBGuideOrientationHorizontal,
    kCCBGuideOrientationVertical
};

@interface GuidesLayer : CCLayer
{
    NSMutableArray* guides;
    int draggingGuide;
    
    CGSize winSize;
    CGPoint stageOrigin;
    float zoom;
}

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event;
- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event;
- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event;
- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm;

- (id) serializeGuides;
- (void) loadSerializedGuides:(id)ser;
- (void) removeAllGuides;
@end
