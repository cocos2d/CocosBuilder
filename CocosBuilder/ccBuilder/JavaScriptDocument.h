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

#import <Cocoa/Cocoa.h>

@class MGSFragaria;
@class SMLTextView;
@class JavaScriptSyntaxChecker;

@interface JavaScriptDocument : NSDocument
{
    IBOutlet NSView* jsView;
    IBOutlet NSWindow* docWindow;
    
    MGSFragaria* fragaria;
    SMLTextView* fragariaTextView;
    
    JavaScriptSyntaxChecker* syntaxChecker;
    IBOutlet NSPopUpButton* warningButton;
    IBOutlet NSPopUpButton* quickJumpButton;
    
    NSString* docStr;
    BOOL docEdited;
    
    BOOL updatingAutoComplete;
}

@property (atomic, copy) NSString* absFileName;

- (void) updateErrors:(NSArray*) errors;
- (void) setHighlightedLine:(int)line;
@end
