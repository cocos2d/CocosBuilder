//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "EditTemplateWindowController.h"
#import "CCBReaderInternalV1.h"
#import "CCBUtil.h"

@implementation EditTemplateWindowController

@synthesize customClass, propertyFile, previewImage, xPreviewAnchorpoint, yPreviewAnchorpoint, pListFiles, imgFiles, canCreatePropertyFile;

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
    NSLog(@"Deallocing window!");
    
    self.customClass = NULL;
    self.propertyFile = NULL;
    self.previewImage = NULL;
    self.xPreviewAnchorpoint = NULL;
    self.yPreviewAnchorpoint = NULL;
    
    self.pListFiles = NULL;
    self.imgFiles = NULL;
    
    [temp release];
    
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

/*
- (void) close
{
    NSLog(@"closing window");
    [[NSApplication sharedApplication] stopModal];
    [super close];
}*/

- (IBAction) pressedSave:(id)sender
{
    [[self window] makeFirstResponder:[self window]];
    
    temp.customClass = self.customClass;
    temp.propertyFile = self.propertyFile;
    temp.previewImage = self.previewImage;
    temp.previewAnchorpoint = ccp([self.xPreviewAnchorpoint floatValue],[self.yPreviewAnchorpoint floatValue]);
    [temp store];
    
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction) pressedCancel:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
}

- (void)popuplateWithTemplate:(CCBTemplate*)t
{
    temp = t;
    [temp retain];
    
    self.pListFiles = [CCBUtil findFilesOfType:@"plist" inDirectory:t.assetsPath];
    self.imgFiles = [CCBUtil findFilesOfType:@"png" inDirectory:t.assetsPath];
    
    self.customClass = [[t.customClass copy] autorelease];
    self.propertyFile = [[t.propertyFile copy] autorelease];
    self.previewImage = [[t.previewImage copy] autorelease];
    self.xPreviewAnchorpoint = [NSNumber numberWithFloat: t.previewAnchorpoint.x];
    self.yPreviewAnchorpoint = [NSNumber numberWithFloat: t.previewAnchorpoint.y];
    
    NSString* defaultPropertyFile = [[temp.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",t.assetsPath, defaultPropertyFile]])
    {
        self.canCreatePropertyFile = YES;
    }
}

- (IBAction) pressedCreateDefaultPropertyFile:(id)sender
{
    self.canCreatePropertyFile = NO;
    
    NSString* defaultPropertyFile = [[temp.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict writeToFile:[NSString stringWithFormat:@"%@%@",temp.assetsPath, defaultPropertyFile] atomically:YES];
    
    self.propertyFile = defaultPropertyFile;
}

@end
