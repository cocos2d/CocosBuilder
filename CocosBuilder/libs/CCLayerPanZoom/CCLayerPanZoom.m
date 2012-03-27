/*
 * CCLayerPanZoom Tests
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2011 Alexey Lang
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
 *
 */


#import "CCLayerPanZoom.h"


#ifdef DEBUG

/** @class CCLayerPanZoomDebugLines Class that represents lines over the CCLayerPanZoom 
 * for debug frame mode */
@interface CCLayerPanZoomDebugLines: CCNode
{
    CGFloat _topFrameMargin;
    CGFloat _bottomFrameMargin;
    CGFloat _leftFrameMargin;
    CGFloat _rightFrameMargin;
}
/** Distance from top edge of contenSize */
@property (readwrite, assign) CGFloat topFrameMargin;
/** Distance from bottom edge of contenSize */
@property (readwrite, assign) CGFloat bottomFrameMargin;
/** Distance from left edge of contenSize */
@property (readwrite, assign) CGFloat leftFrameMargin;
/** Distance from right edge of contenSize */
@property (readwrite, assign) CGFloat rightFrameMargin;

@end

enum nodeTags
{
	kDebugLinesTag,
};

@implementation CCLayerPanZoomDebugLines

@synthesize topFrameMargin = _topFrameMargin, bottomFrameMargin = _bottomFrameMargin, 
            leftFrameMargin = _leftFrameMargin, rightFrameMargin = _rightFrameMargin;

- (void) draw
{
    ccDrawColor4F(1.0f, 0.0f, 0.0f, 1.0);
    glLineWidth(2.0f);    
    ccDrawLine(ccp(self.leftFrameMargin, 0.0f), 
               ccp(self.leftFrameMargin, self.contentSize.height));
    ccDrawLine(ccp(self.contentSize.width - self.rightFrameMargin, 0.0f), 
               ccp(self.contentSize.width - self.rightFrameMargin, self.contentSize.height));
    ccDrawLine(ccp(0.0f, self.bottomFrameMargin), 
               ccp(self.contentSize.width, self.bottomFrameMargin));
    ccDrawLine(ccp(0.0f, self.contentSize.height - self.topFrameMargin), 
               ccp(self.contentSize.width, self.contentSize.height - self.topFrameMargin));
}

@end

#endif


typedef enum
{
    kCCLayerPanZoomFrameEdgeNone,
    kCCLayerPanZoomFrameEdgeTop,
    kCCLayerPanZoomFrameEdgeBottom,
    kCCLayerPanZoomFrameEdgeLeft,
    kCCLayerPanZoomFrameEdgeRight,
    kCCLayerPanZoomFrameEdgeTopLeft,
    kCCLayerPanZoomFrameEdgeBottomLeft,
    kCCLayerPanZoomFrameEdgeTopRight,
    kCCLayerPanZoomFrameEdgeBottomRight
} CCLayerPanZoomFrameEdge;


@interface CCLayerPanZoom ()

@property (readwrite, retain) NSMutableArray *touches;
@property (readwrite, assign) CGFloat touchDistance;
@property (readwrite, retain) CCScheduler *scheduler;
// Return minimum possible scale for the layer considering panBoundsRect and enablePanBounds
- (CGFloat) minPossibleScale;
// Return edge in which current point located
- (CCLayerPanZoomFrameEdge) frameEdgeWithPoint: (CGPoint) point;
// Return horizontal speed in order with current position
- (CGFloat) horSpeedWithPosition: (CGPoint) pos;
// Return vertical speed in order with current position
- (CGFloat) vertSpeedWithPosition: (CGPoint) pos;
// Return distance to top edge of screen
- (CGFloat) topEdgeDistance;
// Return distance to left edge of screen
- (CGFloat) leftEdgeDistance;
// Return distance to bottom edge of screen
- (CGFloat) bottomEdgeDistance;
// Return distance to right edge of screen
- (CGFloat) rightEdgeDistance;
// Recover position if it's need for emulate rubber edges
- (void) recoverPositionAndScale;

@end


@implementation CCLayerPanZoom

@synthesize maxTouchDistanceToClick = _maxTouchDistanceToClick, 
            delegate = _delegate, touches = _touches, touchDistance = _touchDistance, 
            minSpeed = _minSpeed, maxSpeed = _maxSpeed, topFrameMargin = _topFrameMargin, 
            bottomFrameMargin = _bottomFrameMargin, leftFrameMargin = _leftFrameMargin,
            rightFrameMargin = _rightFrameMargin, scheduler = _scheduler, rubberEffectRecoveryTime = _rubberEffectRecoveryTime,
            content = content_, snapToTop = _snapToTop;

@dynamic maxScale; 
- (void) setMaxScale:(CGFloat)maxScale
{
    _maxScale = maxScale;
    self.scale = MIN(self.scale, _maxScale);
}

- (CGFloat) maxScale
{
    return _maxScale;
}

@dynamic minScale;
- (void) setMinScale:(CGFloat)minScale
{
    _minScale = minScale;
    self.scale = MAX(self.scale, minScale);
}

- (CGFloat) minScale
{
    return _minScale;
}

@dynamic rubberEffectRatio;
- (void) setRubberEffectRatio:(CGFloat)rubberEffectRatio
{
    _rubberEffectRatio = rubberEffectRatio;
    
    // Avoid turning rubber effect On in frame mode.
    if (self.mode == kCCLayerPanZoomModeFrame)
    {
        CCLOGERROR(@"CCLayerPanZoom#setRubberEffectRatio: rubber effect is not supported in frame mode.");
        _rubberEffectRatio = 0.0f;
    }
        
}

- (CGFloat) rubberEffectRatio
{
    return _rubberEffectRatio;
}


#pragma mark Init

- (id) init
{
	if ((self = [super init])) 
	{
		self.isRelativeAnchorPoint = YES;
		self.isTouchEnabled = YES;
		
		self.maxScale = 3.0f;
		self.minScale = 0.5f;
		self.touches = [NSMutableArray arrayWithCapacity: 10];
		self.panBoundsRect = CGRectNull;
		self.touchDistance = 0.0F;
		self.maxTouchDistanceToClick = 15.0f;
        
        self.mode = kCCLayerPanZoomModeSheet;
        self.minSpeed = 100.0f;
        self.maxSpeed = 1000.0f;
        self.topFrameMargin = 100.0f;
        self.bottomFrameMargin = 100.0f;
        self.leftFrameMargin = 100.0f;
        self.rightFrameMargin = 100.0f;
        
        self.rubberEffectRatio = 0.5f;
        self.rubberEffectRecoveryTime = 0.2f;
        _rubberEffectRecovering = NO;
        _rubberEffectZooming = NO;
	}	
	return self;
}

#pragma mark CCStandardTouchDelegate Touch events

#ifdef __CC_PLATFORM_IOS

- (void) ccTouchesBegan: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{	
	for (UITouch *touch in [touches allObjects]) 
	{
		// Add new touche to the array with current touches
		[self.touches addObject: touch];
	}
    
    if ([self.touches count] == 1)
    {
        _touchMoveBegan = NO;
        _singleTouchTimestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    else
        _singleTouchTimestamp = INFINITY;
}

- (void) ccTouchesMoved: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
	BOOL multitouch = [self.touches count] > 1;
	if (multitouch)
	{
		// Get the two first touches
        UITouch *touch1 = [self.touches objectAtIndex: 0];
		UITouch *touch2 = [self.touches objectAtIndex: 1];
		// Get current and previous positions of the touches
		CGPoint curPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 locationInView: [touch1 view]]];
		CGPoint curPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 locationInView: [touch2 view]]];
		CGPoint prevPosTouch1 = [[CCDirector sharedDirector] convertToGL: [touch1 previousLocationInView: [touch1 view]]];
		CGPoint prevPosTouch2 = [[CCDirector sharedDirector] convertToGL: [touch2 previousLocationInView: [touch2 view]]];
		// Calculate current and previous positions of the layer relative the anchor point
		CGPoint curPosLayer = ccpMidpoint(curPosTouch1, curPosTouch2);
		CGPoint prevPosLayer = ccpMidpoint(prevPosTouch1, prevPosTouch2);
        
		// Calculate new scale
        CGFloat prevScale = self.scale;
        self.scale = self.scale * ccpDistance(curPosTouch1, curPosTouch2) / ccpDistance(prevPosTouch1, prevPosTouch2);
        // Avoid scaling out from panBoundsRect when Rubber Effect is OFF.
        if (!self.rubberEffectRatio)
        {
            self.scale = MAX(self.scale, [self minPossibleScale]); 
        }
        // If scale was changed -> set new scale and fix position with new scale
        if (self.scale != prevScale)
        {
            if (_rubberEffectRatio)
            {
                _rubberEffectZooming = YES;
            }
            CGPoint realCurPosLayer = [self convertToNodeSpace: curPosLayer];
            CGFloat deltaX = (realCurPosLayer.x - self.anchorPoint.x * self.contentSize.width) * (self.scale - prevScale);
            CGFloat deltaY = (realCurPosLayer.y - self.anchorPoint.y * self.contentSize.height) * (self.scale - prevScale);
            self.position = ccp(self.position.x - deltaX, self.position.y - deltaY);
            _rubberEffectZooming = NO;
        }
        // If current and previous position of the multitouch's center aren't equal -> change position of the layer
		if (!CGPointEqualToPoint(prevPosLayer, curPosLayer))
		{            
            self.position = ccp(self.position.x + curPosLayer.x - prevPosLayer.x,
                                self.position.y + curPosLayer.y - prevPosLayer.y);
        }
        // Don't click with multitouch
		self.touchDistance = INFINITY;
	}
	else
	{	        
        // Get the single touch and it's previous & current position.
        UITouch *touch = [self.touches objectAtIndex: 0];
        CGPoint curTouchPosition = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        CGPoint prevTouchPosition = [[CCDirector sharedDirector] convertToGL: [touch previousLocationInView: [touch view]]];
        
        // Always scroll in sheet mode.
        if (self.mode == kCCLayerPanZoomModeSheet)
        {
            // Set new position of the layer.
            self.position = ccp(self.position.x + curTouchPosition.x - prevTouchPosition.x,
                                self.position.y + curTouchPosition.y - prevTouchPosition.y);
        }
        
        // Accumulate touch distance for all modes.
        self.touchDistance += ccpDistance(curTouchPosition, prevTouchPosition);
        
        // Inform delegate about starting updating touch position, if click isn't possible.
        if (self.mode == kCCLayerPanZoomModeFrame)
        {
            if (self.touchDistance > self.maxTouchDistanceToClick && !_touchMoveBegan)
            {
                [self.delegate layerPanZoom: self 
                   touchMoveBeganAtPosition: [self convertToNodeSpace: prevTouchPosition]];
                _touchMoveBegan = YES;
            }
        }
    }	
}

- (void) ccTouchesEnded: (NSSet *) touches 
			  withEvent: (UIEvent *) event
{
    _singleTouchTimestamp = INFINITY;
    
    // Process click event in single touch.
    if (  (self.touchDistance < self.maxTouchDistanceToClick) && (self.delegate) 
        && ([self.touches count] == 1))
    {
        UITouch *touch = [self.touches objectAtIndex: 0];        
        CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        [self.delegate layerPanZoom: self
                     clickedAtPoint: [self convertToNodeSpace: curPos]
                           tapCount: [touch tapCount]];
    }
    
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[self.touches removeObject: touch];
	}
	if ([self.touches count] == 0)
	{
		self.touchDistance = 0.0f;
	}
    
    if (![self.touches count] && !_rubberEffectRecovering)
    {
        [self recoverPositionAndScale];
    }
}

- (void) ccTouchesCancelled: (NSSet *) touches 
				  withEvent: (UIEvent *) event
{
	for (UITouch *touch in [touches allObjects]) 
	{
		// Remove touche from the array with current touches
		[self.touches removeObject: touch];
	}
	if ([self.touches count] == 0)
	{
		self.touchDistance = 0.0f;
	}
}

#pragma mark Update

// Updates position in frame mode.
- (void) update: (ccTime) dt
{
    // Only for frame mode with one touch.
	if ( self.mode == kCCLayerPanZoomModeFrame && [self.touches count] == 1 )
    {
        // Do not update position if click is still possible.
        if (self.touchDistance <= self.maxTouchDistanceToClick)
            return;
        
        // Do not update position if pinch is still possible.
        if ([NSDate timeIntervalSinceReferenceDate] - _singleTouchTimestamp < kCCLayerPanZoomMultitouchGesturesDetectionDelay)
            return;
        
        // Otherwise - update touch position. Get current position of touch.
        UITouch *touch = [self.touches objectAtIndex: 0];
        CGPoint curPos = [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]];
        
        // Scroll if finger in the scroll area near edge.
        if ([self frameEdgeWithPoint: curPos] != kCCLayerPanZoomFrameEdgeNone)
        {
            self.position = ccp(self.position.x + dt * [self horSpeedWithPosition: curPos], 
                                self.position.y + dt * [self vertSpeedWithPosition: curPos]);
        }
        
        // Inform delegate if touch position in layer was changed due to finger or layer movement.
        CGPoint touchPositionInLayer = [self convertToNodeSpace: curPos];
        if (!CGPointEqualToPoint(_prevSingleTouchPositionInLayer, touchPositionInLayer))
        {
            _prevSingleTouchPositionInLayer = touchPositionInLayer;
            [self.delegate layerPanZoom: self 
                   touchPositionUpdated: touchPositionInLayer];
        }

    }
}

- (void) onEnter
{
    [super onEnter];
	CCScheduler *scheduler = [[CCDirector sharedDirector] scheduler];
    [scheduler scheduleUpdateForTarget: self 
                                                  priority: 0 
                                                    paused: NO];
}

- (void) onExit
{
	CCScheduler *scheduler = [[CCDirector sharedDirector] scheduler];
    [scheduler unscheduleAllSelectorsForTarget: self];
    [super onExit];
}

#endif

#pragma mark Layer Modes related

@dynamic mode;

- (void) setMode: (CCLayerPanZoomMode) mode
{
#ifdef DEBUG
    if (mode == kCCLayerPanZoomModeFrame)
    {
        CCLayerPanZoomDebugLines *lines = [CCLayerPanZoomDebugLines node];
        [lines setContentSize: [CCDirector sharedDirector].winSize];
        lines.topFrameMargin = self.topFrameMargin;
        lines.bottomFrameMargin = self.bottomFrameMargin;
        lines.leftFrameMargin = self.leftFrameMargin;
        lines.rightFrameMargin = self.rightFrameMargin;
        [[CCDirector sharedDirector].runningScene addChild: lines 
                                                         z: NSIntegerMax 
                                                       tag: kDebugLinesTag];
    }
    if (_mode == kCCLayerPanZoomModeFrame)
    {
        [[CCDirector sharedDirector].runningScene removeChildByTag: kDebugLinesTag 
                                                           cleanup: YES];
    }
#endif
    _mode = mode;
    
    // Disable rubber effect in Frame mode.
    if (_mode == kCCLayerPanZoomModeFrame)
    {        
        self.rubberEffectRatio = 0.0f;
    }
}

- (CCLayerPanZoomMode) mode
{
    return _mode;
}

#pragma mark Scale and Position related

@dynamic panBoundsRect;

- (void) setPanBoundsRect: (CGRect) rect
{
	_panBoundsRect = rect;
    self.scale = [self minPossibleScale];
    
    if (_snapToTop)
    {
        CGRect boundBox = [self boundingBox];
        [super setPosition: ccp(rect.origin.x, self.panBoundsRect.size.height + self.panBoundsRect.origin.y - 
                                boundBox.size.height * (1 - self.anchorPoint.y))];
    }
    else
    {
        self.position = rect.origin;
    }
}

- (CGRect) panBoundsRect
{
	return _panBoundsRect;
}

- (void) setPosition: (CGPoint) position
{   
    CGPoint prevPosition = self.position;
    [super setPosition: position];
    if (!CGRectIsNull(_panBoundsRect) && !_rubberEffectZooming)
    {
        if (self.rubberEffectRatio && self.mode == kCCLayerPanZoomModeSheet)
        {
            if (!_rubberEffectRecovering)
            {
                CGFloat topDistance = [self topEdgeDistance];
                CGFloat bottomDistance = [self bottomEdgeDistance];
                CGFloat leftDistance = [self leftEdgeDistance];
                CGFloat rightDistance = [self rightEdgeDistance];
                CGFloat dx = self.position.x - prevPosition.x;
                CGFloat dy = self.position.y - prevPosition.y;
                if (bottomDistance || topDistance)
                {
                    [super setPosition: ccp(self.position.x, 
                                            prevPosition.y + dy * self.rubberEffectRatio)];                    
                }
                if (leftDistance || rightDistance)
                {
                    [super setPosition: ccp(prevPosition.x + dx * self.rubberEffectRatio, 
                                            self.position.y)];                    
                }
            }
        }
        else
        {
            CGRect boundBox = [self boundingBox];
            if (self.position.x - boundBox.size.width * self.anchorPoint.x > self.panBoundsRect.origin.x)
            {
                [super setPosition: ccp(boundBox.size.width * self.anchorPoint.x + self.panBoundsRect.origin.x, 
                                        self.position.y)];
            }	
            if (self.position.y - boundBox.size.height * self.anchorPoint.y > self.panBoundsRect.origin.y)
            {
                [super setPosition: ccp(self.position.x, boundBox.size.height * self.anchorPoint.y + 
                                        self.panBoundsRect.origin.y)];
            }
            if (self.position.x + boundBox.size.width * (1 - self.anchorPoint.x) < self.panBoundsRect.size.width +
                self.panBoundsRect.origin.x)
            {
                [super setPosition: ccp(self.panBoundsRect.size.width + _panBoundsRect.origin.x - 
                                        boundBox.size.width * (1 - self.anchorPoint.x), self.position.y)];
            }
            if (self.position.y + boundBox.size.height * (1 - self.anchorPoint.y) < self.panBoundsRect.size.height + 
                self.panBoundsRect.origin.y)
            {
                [super setPosition: ccp(self.position.x, self.panBoundsRect.size.height + self.panBoundsRect.origin.y - 
                                        boundBox.size.height * (1 - self.anchorPoint.y))];
            }	
        }
    }
}

- (void) setSnapToTop:(BOOL)snapToTop
{
    _snapToTop = snapToTop;
    self.panBoundsRect = self.panBoundsRect;
}

- (void) setScale: (float)scale
{
    [super setScale: MIN(MAX(scale, self.minScale), self.maxScale)];
}

#pragma mark Ruber Edges related

- (void) recoverPositionAndScale
{
    if (!CGRectIsNull(self.panBoundsRect))
	{    
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGFloat rightEdgeDistance = [self rightEdgeDistance];
        CGFloat leftEdgeDistance = [self leftEdgeDistance];
        CGFloat topEdgeDistance = [self topEdgeDistance];
        CGFloat bottomEdgeDistance = [self bottomEdgeDistance];
        CGFloat scale = [self minPossibleScale];
        
        if (!rightEdgeDistance && !leftEdgeDistance && !topEdgeDistance && !bottomEdgeDistance)
        {
            return;
        }
        
        if (self.scale < scale)
        {
            _rubberEffectRecovering = YES;
            CGPoint newPosition = CGPointZero;
            if (rightEdgeDistance && leftEdgeDistance && topEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (self.anchorPoint.x - 0.5f);
                CGFloat dy = scale * self.contentSize.height * (self.anchorPoint.y - 0.5f);
                newPosition = ccp(winSize.width * 0.5f + dx, winSize.height * 0.5f + dy);
            }
            else if (rightEdgeDistance && leftEdgeDistance && topEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (self.anchorPoint.x - 0.5f);
                CGFloat dy = scale * self.contentSize.height * (1.0f - self.anchorPoint.y);            
                newPosition = ccp(winSize.width * 0.5f + dx, winSize.height - dy);
            }
            else if (rightEdgeDistance && leftEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (self.anchorPoint.x - 0.5f);
                CGFloat dy = scale * self.contentSize.height * self.anchorPoint.y;            
                newPosition = ccp(winSize.width * 0.5f + dx, dy);
            }
            else if (rightEdgeDistance && topEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (1.0f - self.anchorPoint.x);
                CGFloat dy = scale * self.contentSize.height * (self.anchorPoint.y - 0.5f);            
                newPosition = ccp(winSize.width  - dx, winSize.height  * 0.5f + dy);
            }
            else if (leftEdgeDistance && topEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * self.anchorPoint.x;
                CGFloat dy = scale * self.contentSize.height * (self.anchorPoint.y - 0.5f);            
                newPosition = ccp(dx, winSize.height * 0.5f + dy);
            }
            else if (leftEdgeDistance && topEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * self.anchorPoint.x;
                CGFloat dy = scale * self.contentSize.height * (1.0f - self.anchorPoint.y);            
                newPosition = ccp(dx, winSize.height - dy);
            } 
            else if (leftEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * self.anchorPoint.x;
                CGFloat dy = scale * self.contentSize.height * self.anchorPoint.y;            
                newPosition = ccp(dx, dy);
            } 
            else if (rightEdgeDistance && topEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (1.0f - self.anchorPoint.x);
                CGFloat dy = scale * self.contentSize.height * (1.0f - self.anchorPoint.y);            
                newPosition = ccp(winSize.width - dx, winSize.height - dy);
            } 
            else if (rightEdgeDistance && bottomEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (1.0f - self.anchorPoint.x);
                CGFloat dy = scale * self.contentSize.height * self.anchorPoint.y;            
                newPosition = ccp(winSize.width - dx, dy);
            } 
            else if (topEdgeDistance || bottomEdgeDistance)
            {
                CGFloat dy = scale * self.contentSize.height * (self.anchorPoint.y - 0.5f);            
                newPosition = ccp(self.position.x, winSize.height * 0.5f + dy);
            }
            else if (leftEdgeDistance || rightEdgeDistance)
            {
                CGFloat dx = scale * self.contentSize.width * (self.anchorPoint.x - 0.5f);
                newPosition = ccp(winSize.width * 0.5f + dx, self.position.y);
            } 
            
            id moveToPosition = [CCMoveTo actionWithDuration: self.rubberEffectRecoveryTime
                                                    position: newPosition];
            id scaleToPosition = [CCScaleTo actionWithDuration: self.rubberEffectRecoveryTime
                                                         scale: scale];
            id sequence = [CCSpawn actions: scaleToPosition, moveToPosition, [CCCallFunc actionWithTarget: self selector: @selector(recoverEnded)], nil];
            [self runAction: sequence];

        }
        else
        {
            _rubberEffectRecovering = YES;
            id moveToPosition = [CCMoveTo actionWithDuration: self.rubberEffectRecoveryTime
                                                    position: ccp(self.position.x + rightEdgeDistance - leftEdgeDistance, 
                                                                  self.position.y + topEdgeDistance - bottomEdgeDistance)];
            id sequence = [CCSpawn actions: moveToPosition, [CCCallFunc actionWithTarget: self selector: @selector(recoverEnded)], nil];
            [self runAction: sequence];
            
        }
	}
}

- (void) recoverEnded
{
    _rubberEffectRecovering = NO;
}

#pragma mark Helpers

- (CGFloat) topEdgeDistance
{
    CGRect boundBox = [self boundingBox];
    return round(MAX(self.panBoundsRect.size.height + self.panBoundsRect.origin.y - self.position.y - 
                     boundBox.size.height * (1 - self.anchorPoint.y), 0));
}

- (CGFloat) leftEdgeDistance
{
    CGRect boundBox = [self boundingBox];
    return round(MAX(self.position.x - boundBox.size.width * self.anchorPoint.x - self.panBoundsRect.origin.x, 0));
}    

- (CGFloat) bottomEdgeDistance
{
    CGRect boundBox = [self boundingBox];
    return round(MAX(self.position.y - boundBox.size.height * self.anchorPoint.y - self.panBoundsRect.origin.y, 0));
}

- (CGFloat) rightEdgeDistance
{
    CGRect boundBox = [self boundingBox];
    return round(MAX(self.panBoundsRect.size.width + self.panBoundsRect.origin.x - self.position.x - 
               boundBox.size.width * (1 - self.anchorPoint.x), 0));
}

- (CGFloat) minPossibleScale
{
	if (!CGRectIsNull(self.panBoundsRect))
	{
		return MAX(self.panBoundsRect.size.width / self.contentSize.width,
				   self.panBoundsRect.size.height / self.contentSize.height);
	}
	else 
	{
		return self.minScale;
	}
}

- (CCLayerPanZoomFrameEdge) frameEdgeWithPoint: (CGPoint) point
{
    BOOL isLeft = point.x <= self.panBoundsRect.origin.x + self.leftFrameMargin;
    BOOL isRight = point.x >= self.panBoundsRect.origin.x + self.panBoundsRect.size.width - self.rightFrameMargin;
    BOOL isBottom = point.y <= self.panBoundsRect.origin.y + self.bottomFrameMargin;
    BOOL isTop = point.y >= self.panBoundsRect.origin.y + self.panBoundsRect.size.height - self.topFrameMargin;
    
    if (isLeft && isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottomLeft;
    }
    if (isLeft && isTop)
    {
        return kCCLayerPanZoomFrameEdgeTopLeft;
    }
    if (isRight && isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottomRight;
    }
    if (isRight && isTop)
    {
        return kCCLayerPanZoomFrameEdgeTopRight;
    }
    
    if (isLeft)
    {
        return kCCLayerPanZoomFrameEdgeLeft;
    }
    if (isTop)
    {
        return kCCLayerPanZoomFrameEdgeTop;
    }
    if (isRight)
    {
        return kCCLayerPanZoomFrameEdgeRight;
    }
    if (isBottom)
    {
        return kCCLayerPanZoomFrameEdgeBottom;
    }
    
    return kCCLayerPanZoomFrameEdgeNone;
}

- (CGFloat) horSpeedWithPosition: (CGPoint) pos
{
    CCLayerPanZoomFrameEdge edge = [self frameEdgeWithPoint: pos];
    CGFloat speed = 0.0f;
    if (edge == kCCLayerPanZoomFrameEdgeLeft)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
        (self.panBoundsRect.origin.x + self.leftFrameMargin - pos.x) / self.leftFrameMargin;
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomLeft || edge == kCCLayerPanZoomFrameEdgeTopLeft)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
        (self.panBoundsRect.origin.x + self.leftFrameMargin - pos.x) / (self.leftFrameMargin * sqrt(2.0f));
    }
    if (edge == kCCLayerPanZoomFrameEdgeRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.x - self.panBoundsRect.origin.x - self.panBoundsRect.size.width + 
             self.rightFrameMargin) / self.rightFrameMargin);
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomRight || edge == kCCLayerPanZoomFrameEdgeTopRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.x - self.panBoundsRect.origin.x - self.panBoundsRect.size.width + 
             self.rightFrameMargin) / (self.rightFrameMargin * sqrt(2.0f)));
    }
    return speed;
}

- (CGFloat) vertSpeedWithPosition: (CGPoint) pos
{
    CCLayerPanZoomFrameEdge edge = [self frameEdgeWithPoint: pos];
    CGFloat speed = 0.0f;
    if (edge == kCCLayerPanZoomFrameEdgeBottom)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (self.panBoundsRect.origin.y + self.bottomFrameMargin - pos.y) / self.bottomFrameMargin;
    }
    if (edge == kCCLayerPanZoomFrameEdgeBottomLeft || edge == kCCLayerPanZoomFrameEdgeBottomRight)
    {
        speed = self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (self.panBoundsRect.origin.y + self.bottomFrameMargin - pos.y) / (self.bottomFrameMargin * sqrt(2.0f));
    }
    if (edge == kCCLayerPanZoomFrameEdgeTop)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.y - self.panBoundsRect.origin.y - self.panBoundsRect.size.height + 
             self.topFrameMargin) / self.topFrameMargin);
    }
    if (edge == kCCLayerPanZoomFrameEdgeTopLeft || edge == kCCLayerPanZoomFrameEdgeTopRight)
    {
        speed = - (self.minSpeed + (self.maxSpeed - self.minSpeed) * 
            (pos.y - self.panBoundsRect.origin.y - self.panBoundsRect.size.height + 
             self.topFrameMargin) / (self.topFrameMargin * sqrt(2.0f)));
    }
    return speed;
}

- (void) setContent:(CCNode *)content
{
    if (content != _content)
    {
        [_content release];
        _content = [content retain];
        
        [self removeAllChildrenWithCleanup:YES];
        if (content)
        {
            [self addChild:content];
            self.contentSize = content.contentSize;
        }
    }
}

- (void) setPanBoundsSize:(CGSize)panBoundsSize
{
    CGRect oldPanBounds = _panBoundsRect;
    self.panBoundsRect = CGRectMake(oldPanBounds.origin.x, oldPanBounds.origin.y, panBoundsSize.width, panBoundsSize.height);
}

- (CGSize) panBoundsSize
{
    return self.panBoundsRect.size;
}

- (void) setPanBoundsOrigin:(CGPoint)panBoundsOrigin
{
    CGRect oldPanBounds = _panBoundsRect;
    self.panBoundsRect = CGRectMake(panBoundsOrigin.x, panBoundsOrigin.y, oldPanBounds.size.width, oldPanBounds.size.height);
}

- (CGPoint) panBoundsOrigin
{
    return self.panBoundsRect.origin;
}

#pragma mark Dealloc

- (void) dealloc
{
	self.touches = nil;
	self.delegate = nil;
	[super dealloc];
}

@end
