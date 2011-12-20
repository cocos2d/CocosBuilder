//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBModalSheetController.h"


@implementation CCBModalSheetController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) finishEditing
{
}

- (IBAction)acceptSheet:(id)sender
{
    [[self window] makeFirstResponder:[self window]];
    NSLog(@"acceptSheet");
    [NSApp stopModalWithCode:1];
}

- (IBAction)cancelSheet:(id)sender
{
    NSLog(@"cancelSheet");
    [NSApp stopModalWithCode:0];
}

- (int) runModalSheetForWindow:(NSWindow*)window
{
    [NSApp beginSheet:[self window] modalForWindow:window modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
    int acceptedModal = (int)[NSApp runModalForWindow:[self window]];
    [NSApp endSheet:[self window]];
    [[self window] close];
    return acceptedModal;
}

/*
+ (int) runModalWindowFromController:(NSWindowController*)wc forWindow:(NSWindow*)window
{
    [NSApp beginSheet:[wc window] modalForWindow:window modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
    int acceptedModal = (int)[NSApp runModalForWindow:[wc window]];
    [NSApp endSheet:[wc window]];
    [[wc window] close];
    return acceptedModal;
}
 */

@end
