//
//  AboutWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/1/13.
//
//

#import "AboutWindow.h"

@interface AboutWindow ()

@end

@implementation AboutWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Load version file into version text field
    NSString* versionPath = [[NSBundle mainBundle] pathForResource:@"Version" ofType:@"txt" inDirectory:@"version"];
    
    NSString* version = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:NULL];
    
    if (version)
    {
        [txtVersion setStringValue:version];
    }
}

@end
