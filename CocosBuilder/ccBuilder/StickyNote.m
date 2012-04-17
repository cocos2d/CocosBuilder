//
//  StickyNote.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StickyNote.h"
#import "CCScale9Sprite.h"
#import "CCBGlobals.h"

@implementation StickyNote

@synthesize docPos, noteText;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.anchorPoint = ccp(0,1);
    self.isRelativeAnchorPoint = YES;
    
    bg = [CCScale9Sprite spriteWithFile:@"notes-bg.png"];
    bg.anchorPoint = ccp(0,0);
    bg.position = ccp(0,0);
    [self addChild:bg z:0];
    
    lbl = [CCLabelTTF labelWithString:@"Double click to edit" fontName:@"MarkerFelt-Thin" fontSize:14];
    lbl.anchorPoint = ccp(0,0);
    lbl.position = ccp(kCCBNoteLblInsetH, kCCBNoteLblInsetBot);
    lbl.verticalAlignment = kCCVerticalTextAlignmentTop;
    lbl.horizontalAlignment = kCCTextAlignmentLeft;
    lbl.color = ccc3(67, 49, 33);
    
    [self addChild:lbl z:1];
    
    [self setContentSize:CGSizeMake(kCCBNoteDefaultWidth, kCCBNoteDefaultHeight)];
    
    return self;
}

- (void) setContentSize:(CGSize)contentSize
{
    bg.preferedSize = contentSize;
    lbl.dimensions = CGSizeMake(contentSize.width - (2*kCCBNoteLblInsetH), contentSize.height -kCCBNoteLblInsetTop - kCCBNoteLblInsetBot);
    
    [super setContentSize:contentSize];
}

- (void) updatePos
{
    self.position = [[[CCBGlobals globals] cocosScene] convertToViewSpace:docPos];
}

- (void) setDocPos:(CGPoint)p
{
    docPos = p;
    [self updatePos];
}

- (int) hitAreaFromPt:(CGPoint)pt
{
    CGPoint localPt = [self convertToNodeSpace:pt];
    
    CGRect resizeRect = CGRectMake(self.contentSize.width-22, 11, 16, 16);
    if (CGRectContainsPoint(resizeRect, localPt)) return kCCBStickyNoteHitResize;
    
    CGRect noteRect = CGRectMake(6, 11, self.contentSize.width-12, self.contentSize.height-18);
    if (CGRectContainsPoint(noteRect, localPt)) return kCCBStickyNoteHitNote;
    
    return kCCBStickyNoteHitNone;
}

- (void) setNoteText:(NSString *)text
{
    [noteText release];
    noteText = [text copy];
    
    if (!noteText)
    {
        [lbl setString:@"Double click to edit"];
    }
    else
    {
        [lbl setString:noteText];
    }
}

- (void) setLabelVisible:(BOOL)labelVisible
{
    lbl.visible = labelVisible;
}

- (BOOL) labelVisible
{
    return lbl.visible;
}

- (void) dealloc
{
    [noteText release];
    [super dealloc];
}

@end
