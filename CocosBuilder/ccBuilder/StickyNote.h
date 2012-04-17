//
//  StickyNote.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#define kCCBNoteDefaultWidth 150
#define kCCBNoteDefaultHeight 150
#define kCCBNoteLblInsetH 10
#define kCCBNoteLblInsetTop 10
#define kCCBNoteLblInsetBot 20

@class CCScale9Sprite;

enum
{
    kCCBStickyNoteHitNone,
    kCCBStickyNoteHitNote,
    kCCBStickyNoteHitResize
};

@interface StickyNote : CCNode
{
    CCScale9Sprite* bg;
    CCLabelTTF* lbl;
    CGPoint docPos;
    NSString* noteText;
}

@property (nonatomic,assign) CGPoint docPos;
@property (nonatomic,copy) NSString* noteText;
@property (nonatomic,assign) BOOL labelVisible;

- (int) hitAreaFromPt:(CGPoint)pt;
- (void) updatePos;

@end
