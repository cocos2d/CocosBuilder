//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBModalSheetController.h"


@implementation CCBModalSheetController

- (IBAction)acceptSheet:(id)sender
{
    if ([[self window] makeFirstResponder:[self window]])
    {
        [NSApp stopModalWithCode:1];
    }
}

- (IBAction)cancelSheet:(id)sender
{
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

@end
