//
//  CCButton.h
//  ZooClient
//
//  Created by Gene Peterson on 1/9/12.
//  Copyright (c) 2012 Zynga Inc. All rights reserved.
//

#import "cocos2d.h"

#define BUTTON_TEXTURE_COUNT 3

@interface CCButton : CCMenuItem
{
    NSArray* textures_;
    ccV2F_C4B_T2F_Quad quads_[BUTTON_TEXTURE_COUNT];
    
    NSString* imageNameFormat;
}

+(CCButton*) buttonWithTarget:(id)target selector:(SEL)selector;
+(CCButton*) buttonWithLabel:(NSString*)text target:(id)target selector:(SEL)selector;
-(CCButton*) initWithLabel:(NSString*)text target:(id)target selector:(SEL)selector;

-(void) setTextures:(NSArray*)textures;

-(NSString*) imageNameFormat;
-(void) setImageNameFormat: (NSString*) format;

-(void) selected;
-(void) unselected;
@end
