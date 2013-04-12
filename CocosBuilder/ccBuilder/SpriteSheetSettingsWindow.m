//
//  SpriteSheetSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 12/19/12.
//
//

#import "SpriteSheetSettingsWindow.h"
#import "Tupac.h"

@interface SpriteSheetSettingsWindow ()

@end

@implementation SpriteSheetSettingsWindow

@synthesize textureFileFormat;
@synthesize compress;
@synthesize dither;
@synthesize textureFileFormatAndroid;
@synthesize ditherAndroid;
@synthesize textureFileFormatHTML5;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateIOSSettings:nil];
    [self updateAndroidSettings:nil];
}

- (IBAction)updateIOSSettings:(NSPopUpButton *)sender {
    BOOL compressEnabled = (textureFileFormat >= kTupacImageFormatPVR_RGBA8888 && textureFileFormat <= kTupacImageFormatPVRTC_2BPP);
    [iosCompress setEnabled:compressEnabled];
    if(!compressEnabled){
        [iosCompress setState:NSOffState];
    }
    BOOL ditherEnabled = (textureFileFormat == kTupacImageFormatPVR_RGBA4444) || (textureFileFormat == kTupacImageFormatPVR_RGB565);
    [iosDither setEnabled:ditherEnabled];
    if(!ditherEnabled){
        [iosDither setState:NSOffState];
    }
}

- (IBAction)updateAndroidSettings:(NSPopUpButton *)sender {
    BOOL ditherEnabled = (textureFileFormatAndroid == kTupacImageFormatPVR_RGBA4444) || (textureFileFormatAndroid == kTupacImageFormatPVR_RGB565);
    [androidDither setEnabled:ditherEnabled];
    if(!ditherEnabled){
        [androidDither setState:NSOffState];
    }
}
@end
