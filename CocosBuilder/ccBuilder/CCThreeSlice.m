//
//  CCThreeSlice.m
//  ZooClient
//
//  Created by Gene Peterson on 1/20/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//

#import "CCThreeSlice.h"
#import "CCNineSlice.h"

#define CCTHREESLICE_COCOS_BUILDER true

#if CCTHREESLICE_COCOS_BUILDER
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#endif

@interface CCThreeSlice(Private)
{
@private
}
-(void) initTextures;
-(void) updateLayout;
@end

@implementation CCThreeSlice

#pragma mark Properties

-(float) innerSize
{
    return innerSize_;
}
-(void) setInnerSize: (float)w
{
    if(w != innerSize_)
    {
        innerSize_ = w;
        [self updateLayout];
    }
}

-(float) innerMin
{
    CCTexture2D* tex0 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:0]];
    float min;
    if(horizontal_)
    {
        float texWidth= tex0.contentSize.width;
        min = -contentSize_.width * anchorPoint_.x + texWidth;
    }
    else
    {
        min = -contentSize_.height * anchorPoint_.y + tex0.contentSize.height;
    }
    return min;
}
-(float) innerMax
{
    float max = self.innerMin + innerSize_;
    return max;
}

-(NSString*) imageNameFormat
{
    return imageNameFormat_;
}
-(void) setImageNameFormat: (NSString*)format
{
    [imageNameFormat_ release];
    imageNameFormat_ = [[format copy] retain];
    [self initTextures];
}

-(BOOL) isHorizontal
{
    return horizontal_;
}
-(void) setIsHorizontal: (BOOL)h
{
    horizontal_ = h;
    [self updateLayout];
}

-(void) setContentSize:(CGSize)size
{
    CCTexture2D* tex0 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:0]];
    CCTexture2D* tex2 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:2]];
	if(self.isHorizontal)
    {
        innerSize_ = size.width - tex0.contentSize.width - tex2.contentSize.width;
    }
    else
    {
        innerSize_ = size.height - tex0.contentSize.height - tex2.contentSize.height;
    }
    [super setContentSize:size];
}

#pragma mark Initializers
-(id) init
{
    imageNameFormat_ = @"bg_banner%d.png";
    if( (self=[super init]) )
    {
        horizontal_ = true;
        self.anchorPoint = ccp(0.5, 0.5);
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
        [self initTextures];
    }
    return self;
}

- (void)dealloc
{
    [textures_ release];
    [super dealloc];
}

-(void)initTextures
{
    NSMutableArray* textures = [[NSMutableArray alloc] init];
    for(int i = 0; i < 3; i++)
    {
#if CCTHREESLICE_COCOS_BUILDER
        CocosBuilderAppDelegate* appDelegate = [[CCBGlobals globals] appDelegate];
        NSString* assetsPath = appDelegate.assetsPath;
        NSString* filename = [NSString stringWithFormat:@"%@%@", assetsPath, [NSString stringWithFormat:imageNameFormat_, i]];
#else
        NSString* filename = [NSString stringWithFormat:imageNameFormat_, i];
#endif
        [[CCTextureCache sharedTextureCache] addImage: filename];
        [textures addObject: filename];
    }
    [self setTextures: textures];
}

-(void) setTextures:(NSArray*)textures
{
	if( textures != textures_ ) {
		[textures_ release];
		textures_ = [textures retain];
		[self updateLayout];
	}
}

-(void)updateLayout
{
    CCTexture2D* tex0 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:0]];
    CCTexture2D* tex2 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:2]];
    
    GLfloat contentWidth = innerSize_;
    GLfloat contentHeight = tex0.contentSize.height;

    contentWidth = ceilf(contentWidth);
    contentHeight = ceilf(contentHeight);
    
    CGFloat widths[3];
    widths[0] = tex0.contentSize.width;
    widths[1] = contentWidth;
    widths[2] = tex2.contentSize.width;
    
    GLfloat width = widths[0] + widths[1] + widths[2];
    GLfloat height = contentHeight;
    
    CGFloat cols[3];
    cols[0] = 0;
    cols[1] = cols[0] + widths[0];
    cols[2] = cols[1] + widths[1];
    
    
    for(int x = 0; x < 3; x++)
    {
        int i = x;
        
        CGFloat left = cols[x];
        CGFloat bottom = 0;
        CGFloat w = widths[x];
        CGFloat h = height;
        
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:i]];
        ccV2F_C4B_T2F_Quad quad = [CCNineSlice createQuad:CGRectMake(left, bottom, w, h) texture: texture];
        quads_[i] = quad;
    }
    
    self.contentSize = CGSizeMake(width, height);
}

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty_ )
    {
        [self updateLayout];
    }
    return [super nodeToParentTransform];
}

- (void) draw
{
#if !CCTHREESLICE_COCOS_BUILDER
	[super draw];
#else
    CC_NODE_DRAW_SETUP();
#endif
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
    for(int i = 0; i < 3; i++) {
        NSString* filename = [textures_ objectAtIndex:i];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage: filename];
        [CCNineSlice drawQuad: quads_[i] texture: texture];
        
	}
}


@end
