//
//  CCThreeSlice.h
//  ZooClient
//
//  Created by Gene Peterson on 1/20/12.
//  Copyright 2012 Zynga Inc. All rights reserved.
//

#import "cocos2d.h"

@interface CCThreeSlice : CCNode {
    BOOL horizontal_;
    NSString* imageNameFormat_;
    float innerSize_;  // width of the inner section for horizontal, height of the inner section for vertical
    
    NSArray* textures_;
    ccV2F_C4B_T2F_Quad quads_[3];
}

@property (nonatomic, retain) NSString* imageNameFormat;
@property (nonatomic, assign) float innerSize;
@property (nonatomic, assign) BOOL isHorizontal;

-(void) setTextures:(NSArray*)textures;

@end
