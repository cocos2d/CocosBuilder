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

#import "GShadowLabelTTF.h"

@interface GShadowLabelTTF(Private)
+ (ccColor3B) getColorByUInt:(GLuint) c;
- (void) updateShadowLabel;
@end

@implementation GShadowLabelTTF

@synthesize shadowType;
@synthesize shadowSize;
@synthesize shadowColor;
@synthesize shadowOpacity;


- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    shadowType = kGShadowType_None;
    shadowSize = 5.0f;
    shadowColor = ccBLACK;
    shadowOpacity = 128;
    shadow_render_tex_ = nil;
    
    return self;
}

-(void) setString:(NSString *)str
{
    if ([str isEqualToString:[super string]])
    {
        return;
    }
    [super setString:str];
    [self updateShadowLabel];
}

-(void) setFontName:(NSString *)fontName
{
    if ([fontName isEqualToString:[super fontName]])
    {
        return;
    }
    [super setFontName:fontName];
    [self updateShadowLabel];
}

-(void) setFontSize:(float)fontSize
{
    if ([super fontSize] == fontSize)
    {
        return;
    }
    [super setFontSize:fontSize];
    [self updateShadowLabel];
}

-(void) setShadowSize:(float)shadow_size
{
    if (self.shadowSize != shadow_size)
    {
        shadowSize = shadow_size;
        [self updateShadowLabel];
    }
}

-(void) setShadowType:(GShadowType)shadow_type
{
    if (self.shadowType != shadow_type)
    {
        shadowType = shadow_type;
        [self updateShadowLabel];
    }
}

-(void) setShadowColor:(ccColor3B)shadow_color
{
    if (self.shadowColor.r!=shadow_color.r ||
        self.shadowColor.g!=shadow_color.g ||
        self.shadowColor.b!=shadow_color.b)
    {
        shadowColor = shadow_color;
        [self updateShadowLabel];
    }
}

-(void) setShadowOpacity:(GLuint)shadow_opacity
{
    if (self.shadowOpacity != shadow_opacity)
    {
        shadowOpacity = shadow_opacity;
        [self updateShadowLabel];
    }
}

#pragma mark private function
- (void) updateShadowLabel
{
    if (shadow_render_tex_ != nil)
    {
        [self removeChild:shadow_render_tex_ cleanup:YES];
        shadow_render_tex_ = nil;
    }
    if (shadowType == kGShadowType_None)
    {
        return;
    }
    CGSize  labelSize = [[self texture] contentSize];
    CGPoint oldAnchorPoint = [self anchorPoint];
    CGPoint oldPos = [self position];
    ccColor3B oldColor = [self color];
    ccBlendFunc oldBlend = [self blendFunc];
    
    ccBlendFunc blendFunc = {GL_SRC_ALPHA,GL_ONE};
    [self setBlendFunc:blendFunc];
    [self setColor:ccWHITE];
    if (shadowType == kGShadowType_Shadow)
    {
        shadow_render_tex_ = [CCRenderTexture renderTextureWithWidth:labelSize.width height:labelSize.height];
        [self setAnchorPoint:ccp(0, 0)];
        [self setPosition:ccp(0, 0)];
        [shadow_render_tex_ beginWithClear:0 g:0 b:0 a:0];
        [self visit];
        [shadow_render_tex_ end];
        CGPoint shadow_pos = ccp(labelSize.width/2+shadowSize,
                                     labelSize.height/2-shadowSize);
        [shadow_render_tex_ setPosition:shadow_pos];
    }
    else if (shadowType == kGShadowType_Edge)
    {
        CGSize shadow_render_tex_size = labelSize;
        shadow_render_tex_size.width += (shadowSize*2);
        shadow_render_tex_size.height += (shadowSize*2);
        shadow_render_tex_ = [CCRenderTexture renderTextureWithWidth:shadow_render_tex_size.width height:shadow_render_tex_size.height];
        
        CGPoint tempPos = ccp(labelSize.width*0.5+shadowSize,
                              labelSize.height*0.5+shadowSize);
        
        [shadow_render_tex_ beginWithClear:0 g:0 b:0 a:0];
        for (int i=0; i<360; i+=1)
        {
            [self setPosition:ccp(tempPos.x + sin(CC_DEGREES_TO_RADIANS(i)*shadowSize), tempPos.y + cos(CC_DEGREES_TO_RADIANS(i))*shadowSize)];
            [self visit];
        }
        [shadow_render_tex_ end];
        
        CGPoint shadow_pos = ccp(labelSize.width/2,labelSize.height/2);
        [shadow_render_tex_ setPosition:shadow_pos];
    }
    [self setAnchorPoint:oldAnchorPoint];
    [self setPosition:oldPos];
    [self setColor:oldColor];
    [self setBlendFunc:oldBlend];
    [[shadow_render_tex_ sprite] setColor:shadowColor];
    [[shadow_render_tex_ sprite] setOpacity:shadowOpacity];
    [self addChild:shadow_render_tex_ z:-1];
}

+ (ccColor3B) ConvertUIntToccColor3B:(GLuint) c
{
    unsigned char r = c >>16;
    unsigned char g = c >>8;
    unsigned char b = c;
    return ccc3(r, g, b);
}
@end
