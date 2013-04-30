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

#import "GCCParticleSystemQuad.h"

@implementation GCCParticleSystemQuad
@synthesize start;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.positionType = kCCPositionTypeGrouped;
    self.start = true;
    
    return self;
}

-(void) setStart:(BOOL)isStart
{
    if (start == isStart)
    {
        return;
    }
    
    start = isStart;
    if (isStart)
    {
        [self resetSystem];
    }
    else
    {
        [self stopSystem];
    }
}

#pragma mark Gravity mode

- (CGPoint) gravity
{
    if (emitterMode_ == kCCParticleModeGravity) return [super gravity];
    else return ccp(0,0);
}

- (void) setGravity:(CGPoint)gravity
{
    if (emitterMode_ == kCCParticleModeGravity) [super setGravity:gravity];
}

- (float) speed
{
    if (emitterMode_ == kCCParticleModeGravity) return [super speed];
    else return 0;
}

- (void) setSpeed:(float)speed
{
    if (emitterMode_ == kCCParticleModeGravity) [super setSpeed:speed];
}

- (float) speedVar
{
    if (emitterMode_ == kCCParticleModeGravity) return [super speedVar];
    else return 0;
}

- (void) setSpeedVar:(float)speedVar
{
    if (emitterMode_ == kCCParticleModeGravity) [super setSpeedVar:speedVar];
}

- (float) tangentialAccel
{
    if (emitterMode_ == kCCParticleModeGravity) return [super tangentialAccel];
    else return 0;
}

- (void) setTangentialAccel:(float)tangentialAccel
{
    if (emitterMode_ == kCCParticleModeGravity) [super setTangentialAccel:tangentialAccel];
}

- (float) tangentialAccelVar
{
    if (emitterMode_ == kCCParticleModeGravity) return [super tangentialAccelVar];
    else return 0;
}

- (void) setTangentialAccelVar:(float)tangentialAccelVar
{
    if (emitterMode_ == kCCParticleModeGravity) [super setTangentialAccelVar:tangentialAccelVar];
}

- (float) radialAccel
{
    if (emitterMode_ == kCCParticleModeGravity) return [super radialAccel];
    else return 0;
}

- (void) setRadialAccel:(float)radialAccel
{
    if (emitterMode_ == kCCParticleModeGravity) [super setRadialAccel:radialAccel];
}

- (float) radialAccelVar
{
    if (emitterMode_ == kCCParticleModeGravity) return [super radialAccelVar];
    else return 0;
}

- (void) setRadialAccelVar:(float)radialAccelVar
{
    if (emitterMode_ == kCCParticleModeGravity) [super setRadialAccelVar:radialAccelVar];
}

#pragma mark Radial mode

- (float) startRadius
{
    if (emitterMode_ == kCCParticleModeRadius) return [super startRadius];
    else return 0;
}

- (void) setStartRadius:(float)startRadius
{
    if (emitterMode_ == kCCParticleModeRadius) [super setStartRadius:startRadius];
}

- (float) startRadiusVar
{
    if (emitterMode_ == kCCParticleModeRadius) return [super startRadiusVar];
    else return 0;
}

- (void) setStartRadiusVar:(float)startRadiusVar
{
    if (emitterMode_ == kCCParticleModeRadius) [super setStartRadiusVar:startRadiusVar];
}

- (float) endRadius
{
    if (emitterMode_ == kCCParticleModeRadius) return [super endRadius];
    else return 0;
}

- (void) setEndRadius:(float)endRadius
{
    if (emitterMode_ == kCCParticleModeRadius) [super setEndRadius:endRadius];
}

- (float) endRadiusVar
{
    if (emitterMode_ == kCCParticleModeRadius) return [super endRadiusVar];
    else return 0;
}

- (void) setEndRadiusVar:(float)endRadiusVar
{
    if (emitterMode_ == kCCParticleModeRadius) [super setEndRadiusVar:endRadiusVar];
}

- (float) rotatePerSecond
{
    if (emitterMode_ == kCCParticleModeRadius) return [super rotatePerSecond];
    else return 0;
}

- (void) setRotatePerSecond:(float)rotatePerSecond
{
    if (emitterMode_ == kCCParticleModeRadius) [super setRotatePerSecond:rotatePerSecond];
}

- (float) rotatePerSecondVar
{
    if (emitterMode_ == kCCParticleModeRadius) return [super rotatePerSecondVar];
    else return 0;
}

- (void) setRotatePerSecondVar:(float)rotatePerSecondVar
{
    if (emitterMode_ == kCCParticleModeRadius) [super setRotatePerSecondVar:rotatePerSecondVar];
}

- (NSArray*) ccbExcludePropertiesForSave
{
    if (emitterMode_ == kCCParticleModeGravity)
    {
        return [NSArray arrayWithObjects:
                @"startRadius",
                @"endRadius",
                @"rotatePerSecond",
                nil];
    }
    else
    {
        return [NSArray arrayWithObjects:
                @"gravity",
                @"speed",
                @"tangentialAccel",
                @"radialAccel",
                nil];
    }
    
    return NULL;
}

@end
