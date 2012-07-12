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
    
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
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
    //[mJavaScriptConsoleInputTextView setString:@"var director = cc.Director.getInstance();\nvar runningScene = director.getRunningScene();\n\nvar sprite = cc.Sprite.create(\"grossini.png\");\nrunningScene.addChild(sprite);"];
    
    if (docStr)
    {
        [fragariaTextView setString:docStr];
        [docStr release];
        docStr = NULL;
    }
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    return [[fragariaTextView string] dataUsingEncoding:NSUTF8StringEncoding];
    
    /*
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;*/
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
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (void) dealloc
{
    [docStr release];
    docStr = NULL;
    [super dealloc];
}

@end
