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
    self.ignoreAnchorPointForPosition = NO;
    
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
    
    NSLog(@"set lbl.dimensions: (%f,%f)", contentSize.width - (2*kCCBNoteLblInsetH), contentSize.height -kCCBNoteLblInsetTop - kCCBNoteLblInsetBot);
    
    lbl.dimensions = CGSizeMake(contentSize.width - (2*kCCBNoteLblInsetH), contentSize.height -kCCBNoteLblInsetTop - kCCBNoteLblInsetBot);
    
    [super setContentSize:contentSize];
}

- (void) updatePos
{
    self.position = [[CocosScene cocosScene] convertToViewSpace:docPos];
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
