//
//  CCBReader.h
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum {
    kCCBPropTypePosition = 0,
    kCCBPropTypeSize,
    kCCBPropTypePoint,
    kCCBPropTypePointLock,
    kCCBPropTypeScaleLock,
    kCCBPropTypeDegrees,
    kCCBPropTypeInteger,
    kCCBPropTypeFloat,
    kCCBPropTypeFloatVar,
    kCCBPropTypeCheck,
    kCCBPropTypeSpriteFrame,
    kCCBPropTypeTexture,
    kCCBPropTypeByte,
    kCCBPropTypeColor3,
    kCCBPropTypeColor4FVar,
    kCCBPropTypeFlip,
    kCCBPropTypeBlendmode,
    kCCBPropTypeFntFile,
    kCCBPropTypeText,
    kCCBPropTypeFontTTF,
    kCCBPropTypeIntegerLabeled,
    kCCBPropTypeBlock
};

enum {
    kCCBFloat0 = 0,
    kCCBFloat1,
    kCCBFloatMinus1,
    kCCBFloat05,
    kCCBFloatInteger,
    kCCBFloatFull
};

enum {
    kCCBPlatformAll = 0,
    kCCBPlatformIOS,
    kCCBPlatformMac
};

enum {
    kCCBTargetTypeNone = 0,
    kCCBTargetTypeDocumentRoot = 1,
    kCCBTargetTypeOwner = 2,
};

@interface CCBReader : NSObject
{
    NSData* data;
    unsigned char* bytes;
    int currentByte;
    int currentBit;
    
    NSMutableArray* stringCache;
    
    CCNode* rootNode;
    id owner;
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file;
+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner;

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString*) file;
+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner;

@end
