//
//  InspectorBlendmode.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorBlendmode.h"

@implementation InspectorBlendmode

- (void) setBlendSrc:(int)blendSrc
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    blend.src = blendSrc;
    
    blendValue = [NSValue value:&blend withObjCType:@encode(ccBlendFunc)];
    [self setPropertyForSelection:blendValue];
}

- (int) blendSrc
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    return blend.src;
}

- (void) setBlendDst:(int)blendDst
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    blend.dst = blendDst;
    
    blendValue = [NSValue value:&blend withObjCType:@encode(ccBlendFunc)];
    [self setPropertyForSelection:blendValue];
}

- (int) blendDst
{
    ccBlendFunc blend;
    NSValue* blendValue = [self propertyForSelection];
    [blendValue getValue:&blend];
    
    return blend.dst;
}

- (IBAction)blendNormal:(id)sender
{
    self.blendSrc = GL_ONE;
    self.blendDst = GL_ONE_MINUS_SRC_ALPHA;
}

- (IBAction)blendAdditive:(id)sender
{
    self.blendSrc = GL_ONE;
    self.blendDst = GL_ONE;
}

- (void) refresh
{
    [self willChangeValueForKey:@"blendSrc"];
    [self didChangeValueForKey:@"blendSrc"];
    
    [self willChangeValueForKey:@"blendDst"];
    [self didChangeValueForKey:@"blendDst"];
}

@end
