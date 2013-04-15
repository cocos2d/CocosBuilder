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

#import "JavaScriptDocument.h"
#import "MGSFragaria.h"
#import "SMLTextView.h"
#import "ResourceManagerUtil.h"
#import "SMLGutterTextView.h"
#import "CocosBuilderAppDelegate.h"
#import "ProjectSettings.h"
#import "SMLLineNumbers.h"
#import "JavaScriptSyntaxChecker.h"
#import "JavaScriptAutoCompleteHandler.h"
#import "SMLSyntaxColouring.h"

@implementation JavaScriptDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"JavaScriptDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    fragaria = [[MGSFragaria alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];
    
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
    
    [fragaria setObject:self forKey:MGSFODelegate];
    [fragaria setObject:[CocosBuilderAppDelegate appDelegate].projectSettings forKey:MGSFOBreakpointDelegate];
    
    NSLog(@"breakpoint delegate: %@ ps: %@", [fragaria objectForKey:MGSFOBreakpointDelegate], [CocosBuilderAppDelegate appDelegate].projectSettings);
    
    // define our syntax definition
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [fragaria embedInView:jsView];
    
    // access the NSTextView
    fragariaTextView = [fragaria objectForKey:ro_MGSFOTextView];
    
    // Setup auto complete
    [fragaria.docSpec setValue:[JavaScriptAutoCompleteHandler autoCompleteHandler] forKey:MGSFOAutoCompleteDelegate];
    
    if (docStr)
    {
        [fragariaTextView setString:docStr];
        
        // Create a new syntax checker for this document
        syntaxChecker = [[JavaScriptSyntaxChecker alloc] init];
        syntaxChecker.document = self;
        
        [syntaxChecker checkText:docStr];
        
        [docStr release];
        docStr = NULL;
    }

    NSString* absFileName = [[self fileURL] path];
    NSString* fileName = [ResourceManagerUtil relativePathFromAbsolutePath:absFileName];

    SMLGutterTextView* gutterView = [[fragaria objectForKey:ro_MGSFOGutterScrollView] documentView];
    gutterView.fileName = fileName;
    
    [[fragaria objectForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [[fragariaTextView string] dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    docStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [fragariaTextView setString:docStr];
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

- (void) updateErrors:(NSArray*) errors
{
    SMLSyntaxColouring* syntaxColouring = [fragaria.docSpec valueForKey:ro_MGSFOSyntaxColouring];
    syntaxColouring.syntaxErrors = errors;
    
    [syntaxColouring pageRecolour];
}

- (void)textDidChange:(NSNotification *)notification
{
    [self updateChangeCount:1];
    docEdited = YES;
    
    [syntaxChecker checkText: [fragariaTextView string]];
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem.title isEqualToString:@"Save"]) return YES;
    return [super validateMenuItem:menuItem];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (IBAction)undo:(id)sender
{
    [fragariaTextView.undoManager undo];
}

- (IBAction)redo:(id)sender
{
    [fragariaTextView.undoManager redo];
}

- (void) dealloc
{
    [docStr release];
    docStr = NULL;
    [super dealloc];
}

@end
