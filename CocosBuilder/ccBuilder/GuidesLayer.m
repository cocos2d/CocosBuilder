//
//  GuidesLayer.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GuidesLayer.h"
#import "CCBGlobals.h"
#import "CCScale9Sprite.h"

#define kCCBGuideGrabAreaWidth 15
#define kCCBGuideMoveAreaRadius 4

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
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
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
    CocosScene* cs = [[CCBGlobals globals] cocosScene];
    
    int g = kCCBGuideNone;
    
    if (pt.x < kCCBGuideGrabAreaWidth)
    {
        g = [self addGuideWithOrientation:kCCBGuideOrientationVertical];
    }
    else if (pt.y < kCCBGuideGrabAreaWidth)
    {
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
    if (draggingGuide != kCCBGuideNone)
    {
        CocosScene* cs = [[CCBGlobals globals] cocosScene];
        CGPoint guidePos = [cs convertToDocSpace:pt];
        
        Guide* g = [guides objectAtIndex:draggingGuide];
        
        if (g->orientation == kCCBGuideOrientationHorizontal)
        {
            g->position = guidePos.y;
        }
        else
        {
            g->position = guidePos.x;
        }
        
        [self updateGuides];
        return YES;
    }
    return NO;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
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

@end
