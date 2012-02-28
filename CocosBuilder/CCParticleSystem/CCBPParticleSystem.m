//
//  CCBPParticleSystem.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBPParticleSystem.h"

@implementation CCBPParticleSystem

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.positionType = kCCPositionTypeGrouped;
    
    return self;
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

@end
