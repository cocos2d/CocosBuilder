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
#import "NSWindow+CCBAccessoryView.h"
#import "SMLSyntaxError.h"
#import "MGSTextMenuController.h"
#import "JavaScriptVariableExtractor.h"

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
    
    //NSLog(@"breakpoint delegate: %@ ps: %@", [fragaria objectForKey:MGSFOBreakpointDelegate], [CocosBuilderAppDelegate appDelegate].projectSettings);
    
    // define our syntax definition
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [fragaria embedInView:jsView];
    
    // access the NSTextView
    fragariaTextView = [fragaria objectForKey:ro_MGSFOTextView];
    
    // Setup auto complete
    [fragaria.docSpec setValue:[JavaScriptAutoCompleteHandler sharedAutoCompleteHandler] forKey:MGSFOAutoCompleteDelegate];
    
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

    self.absFileName = [[self fileURL] path];
    NSString* fileName = [ResourceManagerUtil relativePathFromAbsolutePath:self.absFileName];

    SMLGutterTextView* gutterView = [[fragaria objectForKey:ro_MGSFOGutterScrollView] documentView];
    gutterView.fileName = fileName;
    
    [[fragaria objectForKey:ro_MGSFOLineNumbers] updateLineNumbersCheckWidth:NO recolour:NO];
    
    // Setup warning button
    [warningButton setButtonType:NSMomentaryChangeButton];
    [warningButton setBezelStyle:NSRegularSquareBezelStyle];
    [warningButton.cell setBordered:NO];
    [warningButton.cell setUsesItemFromMenu:NO];
    
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:@"editor-warning.png"]];
    [item setOnStateImage:nil];
    [item setMixedStateImage:nil];
    [[warningButton cell] setMenuItem:item];
    [item release];
    
    [self updateWarningsMenu:[NSArray array]];
    
    // Setup quick jump button
    [quickJumpButton setButtonType:NSMomentaryChangeButton];
    [quickJumpButton setBezelStyle:NSRegularSquareBezelStyle];
    [quickJumpButton.cell setBordered:NO];
    [quickJumpButton.cell setUsesItemFromMenu:NO];
    
    item = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:@"editor-jump.png"]];
    [item setOnStateImage:nil];
    [item setMixedStateImage:nil];
    [[quickJumpButton cell] setMenuItem:item];
    [item release];
    quickJumpButton.title = @"Quick Jump";
    
    [self updateQuickJumpMenu];
}

- (void) updateWarningsMenu:(NSArray*) warnings
{
    NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"Warnings"] autorelease];
    
    NSMenuItem* dummy = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
    [dummy setEnabled:NO];
    [menu addItem:dummy];
    
    if ([warnings count] == 0)
    {
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:@"No Errors in File" action:NULL keyEquivalent:@""] autorelease];
        [item setEnabled:NO];
        [menu addItem:item];
        
        NSMutableAttributedString* title = [[[NSMutableAttributedString alloc] initWithString:@"No Errors in File"] autorelease];
        [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:10] range:NSMakeRange(0, title.string.length)];
        [item setAttributedTitle:title];
        
        [[[warningButton cell] menuItem] setImage:[NSImage imageNamed:@"editor-check.png"]];
        [warningButton setTitle:@"No Errors"];
    }
    else
    {
        [[[warningButton cell] menuItem] setImage:[NSImage imageNamed:@"editor-warning"]];
        [warningButton setTitle:[NSString stringWithFormat:@"%d Errors", (int) warnings.count]];
    }
    
    for (SMLSyntaxError* err in warnings)
    {
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:err.description action:NULL keyEquivalent:@""] autorelease];
        [menu addItem:item];
        
        NSMutableAttributedString* title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"% 4d:  %@", err.line, err.description]];
        NSRange colonRange = [title.string rangeOfString:@":"];
        [title addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(0, colonRange.location + 1)];
        [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:10] range:NSMakeRange(0, title.string.length)];
        [item setAttributedTitle:title];
        
        item.tag = err.line;
        
        [item setTarget:self];
        [item setAction:@selector(pressedWarningBtn:)];
    }
    
    [menu setAutoenablesItems:NO];
    [warningButton setMenu:menu];
    
    [warningButton setNeedsDisplay];
}

- (void) pressedWarningBtn:(id)sender
{
    [[MGSTextMenuController sharedInstance] performGoToLine:(int)[sender tag]];
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
    // Update gutter view
    NSScrollView* gutterScrollView = [fragaria.docSpec valueForKey:@"firstGutterScrollView"];
    SMLGutterTextView* gutter = [gutterScrollView documentView];
    gutter.syntaxErrors = errors;
    [gutter updateSyntaxErrors];
    
    // Update syntax colors
    SMLSyntaxColouring* syntaxColouring = [fragaria.docSpec valueForKey:ro_MGSFOSyntaxColouring];
    syntaxColouring.syntaxErrors = errors;
    
    [syntaxColouring pageRecolour];
    
    // Update warnings menu
    [self updateWarningsMenu:errors];
}

- (void) setHighlightedLine:(int)line
{
    // Update gutter view
    NSScrollView* gutterScrollView = [fragaria.docSpec valueForKey:@"firstGutterScrollView"];
    SMLGutterTextView* gutter = [gutterScrollView documentView];
    
    [gutter setHighlightedLine:line];
    
    if (line > 0)
    {
        [[MGSTextMenuController sharedInstance] performGoToLine:line];
    }
}

- (void) updateQuickJumpMenu
{
    NSArray* functionLocations = [[JavaScriptAutoCompleteHandler sharedAutoCompleteHandler] functionLocationsForFile:self.absFileName];
    
    NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"Warnings"] autorelease];
    
    NSMenuItem* dummy = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
    [dummy setEnabled:NO];
    [menu addItem:dummy];
    
    NSColor* classColor = [NSColor colorWithCalibratedRed:0.15f green:0.28f blue:0.29f alpha:1.0f];
    
    if ([functionLocations count] == 0)
    {
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:@"No Errors in File" action:NULL keyEquivalent:@""] autorelease];
        [item setEnabled:NO];
        [menu addItem:item];
        
        NSMutableAttributedString* title = [[[NSMutableAttributedString alloc] initWithString:@"No Functions Found"] autorelease];
        [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:10] range:NSMakeRange(0, title.string.length)];
        [item setAttributedTitle:title];
    }
    
    for (JavaScriptFunctionLocation* funcLoc in functionLocations)
    {
        NSString* functionName = funcLoc.functionName;
        if (!functionName) functionName = @"<Anonymous>";
        
        NSString* className = NULL;
        if (funcLoc.className)
        {
            className = [NSString stringWithFormat:@"%@.", funcLoc.className];
        }
        else
        {
            className = @"";
        }
        
        NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:functionName action:NULL keyEquivalent:@""] autorelease];
        [menu addItem:item];
        
        NSMutableAttributedString* title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"% 4d:  %@%@", funcLoc.line, className, functionName]];
        
        // Color line numbers
        NSRange colonRange = [title.string rangeOfString:@":"];
        [title addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(0, colonRange.location + 1)];
        
        // Color classes
        NSRange dotRange = [title.string rangeOfString:@"."];
        if (dotRange.location != NSNotFound)
        {
            [title addAttribute:NSForegroundColorAttributeName value:classColor range:NSMakeRange(colonRange.location + 1, dotRange.location - colonRange.location -1)];
        }
        else
        {
            if (![functionName isEqualToString:@"<Anonymous>"])
            {
                NSString* firstChar = [functionName substringToIndex:1];
                if ([[firstChar uppercaseString] isEqualToString:firstChar])
                {
                    // This is a class
                    [title addAttribute:NSForegroundColorAttributeName value:classColor range:NSMakeRange(colonRange.location + 1, title.string.length - (colonRange.location + 1))];
                }
            }
        }
        
        // Set font
        [title addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Menlo" size:10] range:NSMakeRange(0, title.string.length)];
        [item setAttributedTitle:title];
        
        item.tag = funcLoc.line;
        
        [item setTarget:self];
        [item setAction:@selector(pressedWarningBtn:)];
    }
    
    [menu setAutoenablesItems:NO];
    [quickJumpButton setMenu:menu];
}

- (void) updateAutoCompleteAsynch
{
    // Check if update is already being performed
    if (updatingAutoComplete)
    {
        // Try again in a second
        [self performSelector:@selector(updateAutoCompleteAsynch) withObject:NULL afterDelay:1.0];
        return;
    }
    
    updatingAutoComplete = YES;
    
    // Do the update in a background thread
    [self performSelectorInBackground:@selector(performAutoCompleteCheck:) withObject:[[fragariaTextView string] copy]];
    
}

- (void) performAutoCompleteCheck: (NSString*) script
{
    [[JavaScriptAutoCompleteHandler sharedAutoCompleteHandler] loadLocalFile:self.absFileName script:script addWithErrors:NO];
    [script release];
    [self performSelectorOnMainThread:@selector(updateAutoCompleteDone) withObject:NULL waitUntilDone:NO];
}

- (void) updateAutoCompleteDone
{
    updatingAutoComplete = NO;
    
    // Update quick jump menu
    [self updateQuickJumpMenu];
}

- (void)textDidChange:(NSNotification *)notification
{
    [self updateChangeCount:1];
    docEdited = YES;
    
    [syntaxChecker checkText: [fragariaTextView string]];
    [self updateAutoCompleteAsynch];
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
    self.absFileName = NULL;
    [docStr release];
    docStr = NULL;
    [super dealloc];
}

@end
