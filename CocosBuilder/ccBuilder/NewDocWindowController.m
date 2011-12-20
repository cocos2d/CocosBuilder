//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "NewDocWindowController.h"


@implementation NewDocWindowController

@synthesize wStage, hStage;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    self.wStage = 480;
    self.hStage = 320;
    
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

- (IBAction)acceptSheet:(id)sender
{
    [[self window] endEditingFor:hTextField];
    [[self window] endEditingFor:wTextField];
    NSLog(@"acceptSheet");
    [NSApp stopModalWithCode:1];
}

- (IBAction)cancelSheet:(id)sender
{
    NSLog(@"cancelSheet");
    [NSApp stopModalWithCode:0];
}

- (IBAction)changedRootObject:(id)sender
{
    NSLog(@"changedRootObject");
    BOOL selectedParticleSystem = ([[[rootObjectPop selectedItem] title] isEqualToString:@"CCParticleSystem"]);
    
    [templatePop setEnabled:selectedParticleSystem];
}

/*
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"sheetDidEnd");
}*/

- (NSString*) rootObjectType
{
    return [[rootObjectPop selectedItem] title];
}

- (int) templateType
{
    return (int)[[templatePop selectedItem] tag];
}

- (int) originPos
{
    return (int)[radioBtns selectedRow];
}

@end
