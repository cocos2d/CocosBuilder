//
//  CCButton.m
//  ZooClient
//
//  Created by Gene Peterson on 1/9/12.
//  Copyright (c) 2012 Zynga Inc. All rights reserved.
//

#define CCBUTTON_COCOS_BUILDER true

#import "CCButton.h"
#import "CCNineSlice.h"
#if CCBUTTON_COCOS_BUILDER
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#endif


@interface CCButton(private)
{
@private
}
-(void) initTextures;
-(void) updateLayout;
@end

@implementation CCButton

-(id) init
{
    return [self initWithTarget:nil selector:nil];
}

-(id) initWithTarget:(id)target selector:(SEL)selector
{
    imageNameFormat = @"btn_red_pos%d.png";
    if( (self=[super initWithTarget:target selector:selector]) )
    {
        self.anchorPoint = ccp(0.5, 0.5);
        shaderProgram_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
        [self initTextures];
    }
    return self;
}

+(CCButton*) buttonWithTarget:(id)target selector:(SEL)selector
{
    CCButton* button = [[[CCButton alloc] initWithTarget:target selector:selector] autorelease];
    return button;
}

+(CCButton*) buttonWithLabel:(NSString*)text target:(id)target selector:(SEL)selector
{
    CCButton* button = [[[CCButton alloc] initWithLabel:text target:target selector:selector] autorelease];
    return button;
}

-(CCButton*) initWithLabel:(NSString*)text target:(id)target selector:(SEL)selector
{
    if( (self=[self initWithTarget:target selector:selector]) ) {
        CCLabelTTF* label = [CCLabelTTF labelWithString:text fontName:@"Helvetica-Bold" fontSize:24];
        [self addChild:label];
    }
    return self;
}

-(void) addChild: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag
{
    [super addChild:child z:z tag:aTag];
    [self updateLayout];
}

-(void)initTextures
{
    NSMutableArray* textures = [[NSMutableArray alloc] init];
    for(int i = 0; i < BUTTON_TEXTURE_COUNT; i++)
    {
#if CCBUTTON_COCOS_BUILDER
        CocosBuilderAppDelegate* appDelegate = [[CCBGlobals globals] appDelegate];
        NSString* assetsPath = appDelegate.assetsPath;
        NSString* filename = [NSString stringWithFormat:@"%@%@", assetsPath, [NSString stringWithFormat:imageNameFormat, i]];
#else
        NSString* filename = [NSString stringWithFormat:imageNameFormat, i];
#endif
        [[CCTextureCache sharedTextureCache] addImage: filename];
        [textures addObject: filename];
    }
    [self setTextures: textures];
}

-(void) setTextures:(NSArray*)textures
{
    [textures_ release];
    textures_ = textures;
    [self updateLayout];
}

-(NSString*) imageNameFormat
{
    return imageNameFormat;
}

-(void) setImageNameFormat: (NSString*) format
{
    [imageNameFormat release];
    imageNameFormat = [[format copy] retain];
    [self initTextures];
}

-(void)updateLayout
{
    CCTexture2D* tex0 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:0]];
    CCTexture2D* tex2 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:2]];
    
    GLfloat contentWidth = 0;
    GLfloat contentHeight = tex0.contentSize.height;
    if(self.children && [self.children count] > 0)
    {
        for(CCNode* node in self.children)
        {
            contentWidth = MAX(node.contentSize.width, contentWidth);
        }
    }
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
    
    if(self.children && [self.children count] > 0)
    {
        for(CCNode* node in self.children)
        {
            node.position = ccp(width/2, height/2);
        }
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
#if !CCBUTTON_COCOS_BUILDER
	[super draw];
#else
    CC_NODE_DRAW_SETUP();
#endif
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
    for(int i = 0; i < BUTTON_TEXTURE_COUNT; i++) {
        NSString* filename = [textures_ objectAtIndex:i];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage: filename];
        [CCNineSlice drawQuad: quads_[i] texture: texture];
        
	}
}

-(void) selected
{
    ccColor4B color = ccc4(128, 128, 128, 255);
    for(int i = 0; i < BUTTON_TEXTURE_COUNT; i++)
    {
        quads_[i].bl.colors = quads_[i].tl.colors = quads_[i].br.colors = quads_[i].tr.colors = color;
    }
}

-(void) unselected
{
    ccColor4B color = ccc4(255, 255, 255, 255);
    for(int i = 0; i < BUTTON_TEXTURE_COUNT; i++)
    {
        quads_[i].bl.colors = quads_[i].tl.colors = quads_[i].br.colors = quads_[i].tr.colors = color;
    }
}

@end
