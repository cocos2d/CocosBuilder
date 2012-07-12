//
//  JavaScriptDocument.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JavaScriptDocument.h"
#import "MGSFragaria.h"
#import "SMLTextView.h"

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
    
    // define our syntax definition
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    [fragaria embedInView:jsView];
    
    // access the NSTextView
    fragariaTextView = [fragaria objectForKey:ro_MGSFOTextView];
    
    if (docStr)
    {
        [fragariaTextView setString:docStr];
        [docStr release];
        docStr = NULL;
    }
    
    //[self setUndoManager:[fragariaTextView undoManager]];
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


- (void)textDidChange:(NSNotification *)notification
{
    [self updateChangeCount:1];
    docEdited = YES;
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
