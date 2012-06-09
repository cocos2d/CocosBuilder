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

#import "RulersLayer.h"
#import "CCBGlobals.h"

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
    
    mouseMarkVertical = [CCSprite spriteWithFile:@"ruler-guide.png"];
    mouseMarkVertical.anchorPoint = ccp(0, 0.5f);
    mouseMarkVertical.visible = NO;
    [self addChild:mouseMarkVertical z:4];
    
    mouseMarkHorizontal = [CCSprite spriteWithFile:@"ruler-guide.png"];
    mouseMarkHorizontal.rotation = -90;
    mouseMarkHorizontal.anchorPoint = ccp(0, 0.5f);
    mouseMarkHorizontal.visible = NO;
    [self addChild:mouseMarkHorizontal z:4];
    
    CCSprite* xyBg = [CCSprite spriteWithFile:@"ruler-xy.png"];
    [self addChild:xyBg z:5];
    xyBg.anchorPoint = ccp(0,0);
    xyBg.position = ccp(0,0);
    
    lblX = [CCLabelAtlas labelWithString:@"0" charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'-'];
    lblX.anchorPoint = ccp(1,0);
    lblX.position = ccp(47,3);
    lblX.visible = NO;
    [self addChild:lblX z:6];
    
    lblY = [CCLabelAtlas labelWithString:@"0" charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'-'];
    lblY.anchorPoint = ccp(1,0);
    lblY.position = ccp(97,3);
    lblY.visible = NO;
    [self addChild:lblY z:6];
    //lblY = [CCLabelAtlas labelWithString:@"0" charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'0'];
    
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
                
                CCLabelAtlas* lbl = [CCLabelAtlas labelWithString:ch charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'-'];
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
            
            CCLabelAtlas* lbl = [CCLabelAtlas labelWithString:str charMapFile:@"ruler-numbers.png" itemWidth:6 itemHeight:8 startCharMap:'-'];
            lbl.anchorPoint = ccp(0,0);
            lbl.position = ccp(x+1, 1);
            [marksHorizontal addChild:lbl z:1];
        }
        x+=10;
    }
}

- (void)updateMousePos:(CGPoint)pos
{
    mouseMarkHorizontal.position = ccp(pos.x, 0);
    mouseMarkVertical.position = ccp(0, pos.y);
    
    CocosScene* cs = [CocosScene cocosScene];
    CGPoint docPos = [cs convertToDocSpace:pos];
    [lblX setString:[NSString stringWithFormat:@"%d",(int)docPos.x]];
    [lblY setString:[NSString stringWithFormat:@"%d",(int)docPos.y]];
}

- (void)mouseEntered:(NSEvent *)event
{
    mouseMarkHorizontal.visible = YES;
    mouseMarkVertical.visible = YES;
    lblX.visible = YES;
    lblY.visible = YES;
}

- (void)mouseExited:(NSEvent *)event
{
    mouseMarkHorizontal.visible = NO;
    mouseMarkVertical.visible = NO;
    lblX.visible = NO;
    lblY.visible = NO;
}

@end
