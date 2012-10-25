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

#import "NotesLayer.h"
#import "StickyNote.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBTransparentView.h"
#import "CCBTransparentWindow.h"

@implementation NotesLayer

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    notesVisible = YES;
    
    return self;
}

- (void) addNote
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
    StickyNote* note = [[[StickyNote alloc] init] autorelease];
    note.docPos = ccp(10,150);
    [self addChild:note];
}

- (void) editNote:(StickyNote*)note
{
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    
    // Setup text area and add it to guiLayer
    CGSize size = note.contentSize;
    CGPoint pos = ccp(note.position.x, note.position.y - note.contentSize.height);
    
    [NSBundle loadNibNamed:@"StickyNoteEditView" owner:self];
    [editView setFrameOrigin:NSPointFromCGPoint(pos)];
    [editView setFrameSize:NSSizeFromCGSize(size)];
    [ad.guiView addSubview:editView];
    
    [textView setFont:[NSFont fontWithName:@"MarkerFelt-Thin" size:14]];
    [textView setDelegate:self];
    NSString* str = [note noteText];
    if (!str) str = @"";
    [textView setString:str];
    
    // Fix for the close buttons background
    [[closeButton cell] setHighlightsBy:NSContentsCellMask];
    
    // Show the gui window and make it key
    [ad.guiWindow setIsVisible:YES];
    [ad.guiWindow makeKeyWindow];
    [ad.guiWindow makeFirstResponder:textView];
    
    note.labelVisible = NO;
}

- (IBAction)clickedClose:(id)sender
{
    // Remove the sticky note
    [self removeChild:modifiedNote cleanup:YES];
    
    // End the editing session
    CocosBuilderAppDelegate* ad = [CocosBuilderAppDelegate appDelegate];
    [ad.window makeKeyWindow];
    
    modifiedNote = NULL;
}

- (void)textDidChange:(NSNotification *)notification
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
    
    [modifiedNote setNoteText:[textView string]];
}

- (BOOL) mouseDown:(CGPoint)pt event:(NSEvent*)event
{
    modifiedNote = NULL;
    
    if (!self.visible) return NO;
    if (event.modifierFlags & NSCommandKeyMask) return NO;
    
    // Check if the click hits a note
    int hit = kCCBStickyNoteHitNone;
    StickyNote* note = NULL;
    
    CCArray* notes = [self children];
    for (int i = [notes count]-1; i >= 0; i--)
    {
        note = [notes objectAtIndex:i];
        
        hit = [note hitAreaFromPt:pt];
        if (hit != kCCBStickyNoteHitNone) break;
    }
    
    if (hit == kCCBStickyNoteHitNote)
    {
        noteStartPos = note.docPos;
        mouseDownPos = pt;
        operation = kCCBNoteOperationDragging;
        modifiedNote = note;
        
        // Reorder the child to the top
        [note retain];
        [self removeChild:note cleanup:NO];
        [self addChild:note];
        [note release];
        
        return YES;
    }
    else if (hit == kCCBStickyNoteHitResize)
    {
        noteStartSize = note.contentSize;
        mouseDownPos = pt;
        operation = kCCBNoteOperationResizing;
        modifiedNote = note;
        return YES;
    }
    return NO;
}

- (BOOL) mouseDragged:(CGPoint)pt event:(NSEvent*)event
{
    if (operation == kCCBNoteOperationDragging)
    {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
        
        CGPoint delta = ccpSub(pt, mouseDownPos);
        modifiedNote.docPos = ccpAdd(noteStartPos, delta);
        return YES;
    }
    else if (operation == kCCBNoteOperationResizing)
    {
        [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*notes"];
        
        CGPoint delta = ccpSub(pt, mouseDownPos);
        CGSize newSize;
        newSize.width = noteStartSize.width + delta.x;
        newSize.height = noteStartSize.height - delta.y;
        
        if (newSize.width < 60) newSize.width = 60;
        if (newSize.height < 60) newSize.height = 60;
        
        modifiedNote.contentSize = newSize;
        return YES;
    }
    
    return NO;
}

- (BOOL) mouseUp:(CGPoint)pt event:(NSEvent*)event
{
    if (operation == kCCBNoteOperationDragging
        && event.clickCount == 2
        && [modifiedNote hitAreaFromPt:pt] == kCCBNoteOperationDragging)
    {
        [self editNote:modifiedNote];
        return YES;
    }
    
    operation = kCCBNoteOperationNone;
    //modifiedNote = NULL;
    
    return NO;
}

- (void) updateWithSize:(CGSize)ws stageOrigin:(CGPoint)so zoom:(float)zm
{
    if (!self.visible) return;
    
    if (CGSizeEqualToSize(ws, winSize)
        && CGPointEqualToPoint(so, stageOrigin)
        && zm == zoom)
    {
        return;
    }
    
    // Store values
    winSize = ws;
    stageOrigin = so;
    zoom = zm;
    
    [super setVisible: (zoom == 1 && notesVisible)];
    
    
    CCArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        [note updatePos];
    }
}

- (BOOL) visible
{
    return notesVisible;
}

- (void) setVisible:(BOOL)visible
{
    notesVisible = visible;
    [super setVisible:(zoom == 1 && notesVisible)];
}

- (void) showAllNotesLabels
{
    modifiedNote = NULL;
    
    CCArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        note.labelVisible = YES;
    }
}

- (void) removeAllNotes
{
    [self removeAllChildrenWithCleanup:YES];
}

- (void) loadSerializedNotes:(id)ser
{
    [self removeAllChildrenWithCleanup:YES];
    
    for (NSDictionary* serNote in ser)
    {
        StickyNote* note = [[[StickyNote alloc] init] autorelease];
        
        // Load text
        note.noteText = [serNote objectForKey:@"text"];
        
        // Load position
        CGPoint pos = ccp([[serNote objectForKey:@"xPos"] floatValue],[[serNote objectForKey:@"yPos"] floatValue]);
        note.docPos = pos;
        
        // Load size
        note.contentSize = CGSizeMake([[serNote objectForKey:@"width"] floatValue], [[serNote objectForKey:@"height"] floatValue]);
        
        [self addChild:note];
    }
}

- (id) serializeNotes
{
    NSMutableArray* ser = [NSMutableArray array];
    
    CCArray* notes = [self children];
    for (int i = 0; i < [notes count]; i++)
    {
        StickyNote* note = [notes objectAtIndex:i];
        
        NSMutableDictionary* serNote = [NSMutableDictionary dictionary];
        if (note.noteText)
        {
            [serNote setObject:note.noteText forKey:@"text"];
        }
        [serNote setObject:[NSNumber numberWithFloat: note.contentSize.width] forKey:@"width"];
        [serNote setObject:[NSNumber numberWithFloat: note.contentSize.height] forKey:@"height"];
        [serNote setObject:[NSNumber numberWithFloat: note.docPos.x] forKey:@"xPos"];
        [serNote setObject:[NSNumber numberWithFloat: note.docPos.y] forKey:@"yPos"];
        
        [ser addObject:serNote];
    }
    
    return ser;
}

@end
