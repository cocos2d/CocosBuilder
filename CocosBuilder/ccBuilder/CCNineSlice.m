//
//  CCNineSlice.m
//  ZooClient
//
//  Created by Gene Peterson on 1/12/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//

#import "CCNineSlice.h"

#define CCNINESLICE_COCOS_BUILDER true

#if CCNINESLICE_COCOS_BUILDER
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#endif

@interface CCNineSlice(private)
{
@private
}
-(void)initTextures;
-(void)updateLayout;
@end

@implementation CCNineSlice

-(id)init
{
    if(self = [super init])
    {
        self.anchorPoint = ccp(0.5, 0.5);
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
        [self initTextures];
        [self updateLayout];
    }
    return self;
}

- (void)dealloc
{
	[textures_ release];

    [super dealloc];
}

+(ccV2F_C4B_T2F_Quad) createQuad:(CGRect)rect texture:(CCTexture2D*) texture
{
    GLfloat left = rect.origin.x;
    GLfloat right = rect.origin.x + rect.size.width;
    GLfloat top = rect.origin.y + rect.size.height;
    GLfloat bottom = rect.origin.y;
    
    ccV2F_C4B_T2F_Quad quad;
    bzero(&quad, sizeof(quad));
    ccColor4B color = ccc4(255, 255, 255, 255);
    quad.bl.colors = quad.tl.colors = quad.br.colors = quad.tr.colors = color;
    quad.bl.vertices = (ccVertex2F){left, bottom};
    quad.tl.vertices = (ccVertex2F){left, top};
    quad.tr.vertices = (ccVertex2F){right, top};
    quad.br.vertices = (ccVertex2F){right, bottom};
    quad.bl.texCoords = (ccTex2F){0,1};
    quad.tl.texCoords = (ccTex2F){0,0};
    quad.tr.texCoords = (ccTex2F){1,0};
    quad.br.texCoords = (ccTex2F){1,1};
    return quad;
}

-(void)updateLayout
{
    // grab 3 of the 4 corners, used in calculating the sizes of the scalable sections
    CCTexture2D* tex0 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:0]];
    CCTexture2D* tex2 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:2]];
    CCTexture2D* tex6 = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:6]];
    
    CGSize size = contentSize_;
    GLfloat minWidth = tex0.contentSize.width + tex2.contentSize.width;
    GLfloat minHeight = tex0.contentSize.height + tex6.contentSize.height;
    
    size = CGSizeMake(MAX(minWidth, size.width), MAX(minHeight, size.height));
    GLfloat width = size.width;
    GLfloat height = size.height;
    
    GLfloat innerWidth = width - minWidth;
    GLfloat innerHeight = height - minHeight;
     
    CGFloat widths[3];
    widths[0] = tex0.contentSize.width;
    widths[1] = innerWidth;
    widths[2] = tex2.contentSize.width;
    
    CGFloat heights[3];
    heights[0] = tex0.contentSize.height;
    heights[1] = innerHeight;
    heights[2] = tex6.contentSize.height;
    
    CGFloat rows[3];
    rows[0] = 0;
    rows[1] = rows[0] + heights[0];
    rows[2] = rows[1] + heights[1];
    
    CGFloat cols[3];
    cols[0] = 0;
    cols[1] = cols[0] + widths[0];
    cols[2] = cols[1] + widths[1];
        
    for(int y = 0; y < 3; y++)
    {
        for(int x = 0; x < 3; x++)
        {
            int i = (2-y) * 3 + x;
            
            CGFloat left = cols[x];
            CGFloat bottom = rows[y];
            CGFloat w = widths[x];
            CGFloat h = heights[y];
            
            CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage: [textures_ objectAtIndex:i]];
            ccV2F_C4B_T2F_Quad quad = [CCNineSlice createQuad:CGRectMake(left, bottom, w, h) texture:texture];
            quads_[i] = quad;
        }
    }
    
    self.contentSize = CGSizeMake(width, height);
}

-(void)initTextures
{
    NSMutableArray* textures = [[NSMutableArray alloc] init];
    for(int i = 0; i < 9; i++)
    {
        NSString* imageNameFormat = @"DialogComposite_0%d.png";
#if CCNINESLICE_COCOS_BUILDER
        CocosBuilderAppDelegate* appDelegate = [[CCBGlobals globals] appDelegate];
        NSString* assetsPath = appDelegate.assetsPath;
        NSString* filename = [NSString stringWithFormat:@"%@%@", assetsPath, [NSString stringWithFormat:imageNameFormat, i+1]];
#else
        NSString* filename = [NSString stringWithFormat:imageNameFormat, i+1];
#endif
        [[CCTextureCache sharedTextureCache] addImage: filename];
        [textures addObject: filename];
    }
    textures_ = textures;
}

-(void) setTextures: (NSArray*)textures
{
	if( textures != textures_ ) {
		[textures_ release];
		textures_ = [textures retain];
		[self updateLayout];
	}
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
#if !CCNINESLICE_COCOS_BUILDER
	[super draw];
#else
    CC_NODE_DRAW_SETUP();
#endif

    ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
    for(int i = 0; i < 9; i++) {
        NSString* filename = [textures_ objectAtIndex:i];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage: filename];
        [CCNineSlice drawQuad: quads_[i] texture: texture];
	}
}

+(void)drawQuad:(ccV2F_C4B_T2F_Quad)quad texture:(CCTexture2D*)texture
{
    ccGLBindTexture2D( [texture name] );
    
#define kQuadSize sizeof(quad.bl)
	long offset = (long)&quad;
	
	// vertex
	NSInteger diff = offsetof( ccV2F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
	
	// texCoods
	diff = offsetof( ccV2F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV2F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CHECK_GL_ERROR_DEBUG();
	
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad.tl.vertices.x,quad.tl.vertices.y),
		ccp(quad.bl.vertices.x,quad.bl.vertices.y),
		ccp(quad.br.vertices.x,quad.br.vertices.y),
		ccp(quad.tr.vertices.x,quad.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
}


@end
