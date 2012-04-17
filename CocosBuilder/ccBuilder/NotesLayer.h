//
//  NotesLayer.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

enum
{
    kCCBNoteOperationNone,
    kCCBNoteOperationDragging,
    kCCBNoteOperationResizing
};

@class StickyNote;

@interface NotesLayer : CCLayer <NSTextViewDelegate>
{
    CGSize winSize;
    CGPoint stageOrigin;
    float zoom;
    
    BOOL notesVisible;
    
    int operation;
    CGPoint mouseDownPos;
    CGPoint noteStartPos;
    CGSize noteStartSize;
    StickyNote* modifiedNote;
    
    IBOutlet NSView* editView;
    IBOutlet NSTextView* textView;
    IBOutlet NSButton* closeButton;
}
- (void) addNote;
- (IBAction)clickedClose:(id)sender;
- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event;
- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event;
- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event;

- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm;
- (void) showAllNotesLabels;

- (void) loadSerializedNotes:(id)ser;
- (id) serializeNotes;
- (void) removeAllNotes;

@end
