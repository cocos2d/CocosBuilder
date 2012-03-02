//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "NewDocWindowController.h"
#import "PlugInManager.h"

@implementation NewDocWindowController

@synthesize wStage, hStage,rootObjectType, rootObjectTypes, centeredStageOrigin;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    self.wStage = 480;
    self.hStage = 320;
    
    self.rootObjectTypes = [PlugInManager sharedManager].plugInsNodeNamesCanBeRoot;
    self.rootObjectType = [rootObjectTypes objectAtIndex:0];
    
    self.centeredStageOrigin = 0;
    
    return self;
}

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

- (void) dealloc
{
    self.rootObjectType = NULL;
    [super dealloc];
}

@end
