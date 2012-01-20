//
//  CCNineSlice.h
//  ZooClient
//
//  Created by Gene Peterson on 1/12/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCNineSlice : CCNode {
    NSArray* textures_;
    ccV2F_C4B_T2F_Quad quads_[9];
}

+(ccV2F_C4B_T2F_Quad) createQuad:(CGRect)rect texture:(CCTexture2D*) texture;
+(void)drawQuad:(ccV2F_C4B_T2F_Quad)quad texture:(CCTexture2D*)texture;

-(void) setTextures: (NSArray*) textures;
@end
