//
//  SpriteSheetSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 12/19/12.
//
//

#import "SpriteSheetSettingsWindow.h"

@interface SpriteSheetSettingsWindow ()

@end

@implementation SpriteSheetSettingsWindow

@synthesize textureFileFormat;
@synthesize compress;
@synthesize dither;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
