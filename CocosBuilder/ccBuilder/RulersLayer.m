//
//  RulersLayer.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RulersLayer.h"

#define kCCBRulerWidth 15

@implementation RulersLayer

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    bgVertical = [CCScale9Sprite spriteWithFile:@"ruler-bg-vertical.png"];
    bgVertical.anchorPoint = ccp(0,0);
    
    bgHorizontal = [CCScale9Sprite spriteWithFile:@"ruler-bg-horizontal.png"];
    bgHorizontal.anchorPoint = ccp(0,0);
    
    [self addChild:bgVertical];
    [self addChild:bgHorizontal z:2];
    
    marksVertical = [CCNode node];
    marksHorizontal = [CCNode node];
    [self addChild:marksVertical z:1];
    [self addChild:marksHorizontal z:3];
    
    return self;
}

- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm
{
    stageOrigin.x = (int) stageOrigin.x;
    stageOrigin.y = (int) stageOrigin.y;
    
    if (CGSizeEqualToSize(ws, winSize)
        && CGPointEqualToPoint(so, stageOrigin)
        && zm == zoom)
    {
        return;
    }
    
    // Store values
    winSize = ws;
    stageOrigin = so;
    zoom = zm;
    
    // Resize backrounds
    bgHorizontal.preferedSize = CGSizeMake(winSize.width, kCCBRulerWidth);
    bgVertical.preferedSize = CGSizeMake(kCCBRulerWidth, winSize.height);
    
    // Add marks and numbers
    [marksVertical removeAllChildrenWithCleanup:YES];
    [marksHorizontal removeAllChildrenWithCleanup:YES];
    
    // Vertical marks
    int y = (int)so.y - (((int)so.y)/10)*10;
    while (y < winSize.height)
    {
        int yDist = abs(y - (int)stageOrigin.y);
        
        CCSprite* mark = NULL;
        BOOL addLabel = NO;
        if (yDist == 0)
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-origin.png"];
            addLabel = YES;
        }
        else if (yDist % 50 == 0)
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-major.png"];
            addLabel = YES;
        }
        else
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-minor.png"];
        }
        mark.anchorPoint = ccp(0, 0.5f);
        mark.position = ccp(0, y);
        [marksVertical addChild:mark];
        
        if (addLabel)
        {
            int displayDist = yDist / zoom;
            NSString* str = [NSString stringWithFormat:@"%d",displayDist];
            int strLen = [str length];
            
            for (int i = 0; i < strLen; i++)
            {
                NSString* ch = [str substringWithRange:NSMakeRange(i, 1)];
                
                CCLabelAtlas* lbl = [CCLabelAtlas labelWithString:ch charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'0'];
                lbl.anchorPoint = ccp(0,0);
                lbl.position = ccp(2, y + 1 + 8* (strLen - i - 1));
            
                [marksVertical addChild:lbl z:1];
            }
        }
        y+=10;
    }
    
    // Horizontal marks
    int x = (int)so.x - (((int)so.x)/10)*10;
    while (x < winSize.width)
    {
        int xDist = abs(x - (int)stageOrigin.x);
        
        CCSprite* mark = NULL;
        BOOL addLabel = NO;
        if (xDist == 0)
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-origin.png"];
            addLabel = YES;
        }
        else if (xDist % 50 == 0)
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-major.png"];
            addLabel = YES;
        }
        else
        {
            mark = [CCSprite spriteWithFile:@"ruler-mark-minor.png"];
        }
        mark.anchorPoint = ccp(0, 0.5f);
        mark.position = ccp(x, 0);
        mark.rotation = -90;
        [marksHorizontal addChild:mark];
        
        
        if (addLabel)
        {
            int displayDist = xDist / zoom;
            NSString* str = [NSString stringWithFormat:@"%d",displayDist];
            
            CCLabelAtlas* lbl = [CCLabelAtlas labelWithString:str charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'0'];
            lbl.anchorPoint = ccp(0,0);
            lbl.position = ccp(x+1, 1);
            [marksHorizontal addChild:lbl z:1];
        }
        x+=10;
    }
}

@end
