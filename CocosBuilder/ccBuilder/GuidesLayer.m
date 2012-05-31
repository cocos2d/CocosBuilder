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

#import "GuidesLayer.h"
#import "CCBGlobals.h"
#import "CCScale9Sprite.h"
#import "CocosBuilderAppDelegate.h"

#define kCCBGuideGrabAreaWidth 15
#define kCCBGuideMoveAreaRadius 4
#define kCCBGuideSnapDistance 4

#pragma mark Guide
@interface Guide : NSObject
{
    @public
    float position;
    int orientation;
}
@end

@implementation Guide
@end

#pragma mark GuidesLayer

@implementation GuidesLayer

- (id)init
{
    self = [super init];
    if (!self) return NULL;
    
    draggingGuide = kCCBGuideNone;
    guides = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc
{
    [guides release];
    [super dealloc];
}

- (void) updateGuides
{
    CocosScene* cs = [CocosScene cocosScene];
    
    [self removeAllChildrenWithCleanup:YES];
    
    CGRect viewRect = CGRectZero;
    viewRect.size = winSize;
    
    for (Guide* g in guides)
    {
        if (g->orientation == kCCBGuideOrientationHorizontal)
        {
            CGPoint viewPos = [cs convertToViewSpace:ccp(0,g->position)];
            viewPos.x = 0;
            
            if (CGRectContainsPoint(viewRect, viewPos))
            {
                CCScale9Sprite* sprtGuide = [CCScale9Sprite spriteWithFile:@"ruler-guide.png"];
                sprtGuide.preferedSize = CGSizeMake(winSize.width, 2);
                sprtGuide.anchorPoint = ccp(0, 0.5f);
                sprtGuide.position = viewPos;
                [self addChild:sprtGuide];
            }
        }
        else
        {
            CGPoint viewPos = [cs convertToViewSpace:ccp(g->position,0)];
            viewPos.y = 0;
            
            if (CGRectContainsPoint(viewRect, viewPos))
            {
                CCScale9Sprite* sprtGuide = [CCScale9Sprite spriteWithFile:@"ruler-guide.png"];
                sprtGuide.preferedSize = CGSizeMake(winSize.height, 2);
                sprtGuide.anchorPoint = ccp(0, 0.5f);
                sprtGuide.rotation = -90;
                sprtGuide.position = viewPos;
                [self addChild:sprtGuide];
            }
        }
    }
}

- (int) addGuideWithOrientation:(int)orientation
{
    Guide* g = [[[Guide alloc] init] autorelease];
    g->orientation = orientation;
    
    [guides addObject:g];
    return [guides count]-1;
}

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event
{
    if (!self.visible) return NO;
    
    CocosScene* cs = [CocosScene cocosScene];
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    int g = kCCBGuideNone;
    
    if (pt.x < kCCBGuideGrabAreaWidth)
    {
        [ad saveUndoStateWillChangeProperty:@"*guide"];
        g = [self addGuideWithOrientation:kCCBGuideOrientationVertical];
    }
    else if (pt.y < kCCBGuideGrabAreaWidth)
    {
        [ad saveUndoStateWillChangeProperty:@"*guide"];
        g = [self addGuideWithOrientation:kCCBGuideOrientationHorizontal];
    }
    else if (event.modifierFlags & NSCommandKeyMask)
    {
        // Check if we should drag guides
        for (int i = 0; i < [guides count]; i++)
        {
            Guide* guide = [guides objectAtIndex:i];
            
            if (guide->orientation == kCCBGuideOrientationHorizontal)
            {
                CGPoint viewPos = [cs convertToViewSpace:ccp(0,guide->position)];
                viewPos.x = 0;
                
                if (pt.y > viewPos.y - kCCBGuideMoveAreaRadius
                    && pt.y < viewPos.y+ kCCBGuideMoveAreaRadius)
                {
                    [ad saveUndoStateWillChangeProperty:@"*guide"];
                    g = i;
                    break;
                }
            }
            else
            {
                CGPoint viewPos = [cs convertToViewSpace:ccp(guide->position,0)];
                viewPos.y = 0;
                
                if (pt.x > viewPos.x - kCCBGuideMoveAreaRadius
                    && pt.x < viewPos.x+ kCCBGuideMoveAreaRadius)
                {
                    [ad saveUndoStateWillChangeProperty:@"*guide"];
                    g = i;
                    break;
                }
            }
        }
    }
    
    if (g != kCCBGuideNone)
    {
        draggingGuide = g;
        return YES;
    }
    
    return NO;
}

- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event
{
    if (!self.visible) return NO;
    
    if (draggingGuide != kCCBGuideNone)
    {
        CocosScene* cs = [CocosScene cocosScene];
        CGPoint guidePos = [cs convertToDocSpace:pt];
        
        Guide* g = [guides objectAtIndex:draggingGuide];
        
        if (g->orientation == kCCBGuideOrientationHorizontal)
        {
            g->position = (int)guidePos.y;
        }
        else
        {
            g->position = (int)guidePos.x;
        }
        
        [self updateGuides];
        return YES;
    }
    return NO;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
    if (!self.visible) return NO;
    
    if (draggingGuide != kCCBGuideNone)
    {
        Guide* g = [guides objectAtIndex:draggingGuide];
        
        if (g->orientation == kCCBGuideOrientationHorizontal
            && (pt.y < kCCBGuideGrabAreaWidth
                || pt.y >= winSize.height))
        {
            // Remove guide
            [guides removeObjectAtIndex:draggingGuide];
        }
        else if (g->orientation == kCCBGuideOrientationVertical
            && (pt.x < kCCBGuideGrabAreaWidth
                || pt.x >= winSize.width))
        {
            // Remove guide
            [guides removeObjectAtIndex:draggingGuide];
        }
        
        draggingGuide = kCCBGuideNone;
        return YES;
    }
    return NO;
}

- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm
{
    if (!self.visible) return;
    
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
    
    [self updateGuides];
}

- (id) serializeGuides
{
    NSMutableArray* ser = [NSMutableArray array];
    
    for (Guide* g in guides)
    {
        NSMutableDictionary* gDict = [NSMutableDictionary dictionary];
        
        [gDict setObject:[NSNumber numberWithInt:g->orientation] forKey:@"orientation"];
        [gDict setObject:[NSNumber numberWithFloat:g->position] forKey:@"position"];
        
        [ser addObject:gDict];
    }
    
    return ser;
}

- (void) loadSerializedGuides:(id)ser
{
    if (![ser isKindOfClass:[NSArray class]]) return;
    
    [guides removeAllObjects];
    
    for (NSDictionary* gDict in ser)
    {
        int orientation = [[gDict objectForKey:@"orientation"] intValue];
        float pos = [[gDict objectForKey:@"position"] floatValue];
        
        Guide* g = [[[Guide alloc] init] autorelease];
        g->position = pos;
        g->orientation = orientation;
        [guides addObject:g];
    }
    
    [self updateGuides];
}

- (void) removeAllGuides
{
    [guides removeAllObjects];
    [self updateGuides];
}

- (CGPoint) snapPoint:(CGPoint)pt
{
    CGPoint snappedPt = pt;
    
    CocosScene* cs = [CocosScene cocosScene];
    float minSnapDistX = kCCBGuideSnapDistance;
    float minSnapDistY = kCCBGuideSnapDistance;
    
    for (Guide* g in guides)
    {
        if (g->orientation == kCCBGuideOrientationHorizontal)
        {
            CGPoint viewPos = [cs convertToViewSpace:ccp(0,g->position)];
            
            float snapDist = fabs(pt.y - viewPos.y);
            if (snapDist < minSnapDistY)
            {
                snappedPt.y = viewPos.y;
                minSnapDistY = snapDist;
            }
        }
        else
        {
            CGPoint viewPos = [cs convertToViewSpace:ccp(g->position,0)];
            
            float snapDist = fabs(pt.x - viewPos.x);
            if (snapDist < minSnapDistX)
            {
                snappedPt.x = viewPos.x;
                minSnapDistX = snapDist;
            }
        }
    }
    
    return snappedPt;
}

@end
