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
    kCCBPropTypeBlock,
	kCCBPropTypeAnimation,
    kCCBPropTypeCCBFile
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

@interface CCBFile : CCNode
{
    CCNode* ccbFile;
}
@property (nonatomic,retain) CCNode* ccbFile;
@end
