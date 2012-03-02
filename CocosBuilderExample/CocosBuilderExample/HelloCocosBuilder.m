//
//  HelloCocosBuilder.m
//  CocosBuilderTest
//

#import "HelloCocosBuilder.h"


@implementation HelloCocosBuilder

// This method is called right after the class has been instantiated
// by CCBReader. Do any additional initiation here. If no extra
// initialization is needed, leave this method out.
- (void) didLoadFromCCB
{    
    // Start rotating the burst sprite
    [sprtBurst runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:20.0f angle:360]]];
}

// This method is set as an attribute to the CCMenuItemImage in
// CocosBuilder, and automatically set up to be called when the
// button is pressed.
- (void) pressedButton:(id)sender
{
    NSLog(@"pressedButton");
    
    // Stop all runnint actions for the icon sprite
    [sprtIcon stopAllActions];
    
    // Reset the rotation of the icon
    sprtIcon.rotation = 0;
    
    // Rotate the sprtIcon 360 degrees
    [sprtIcon runAction:[CCRotateBy actionWithDuration:1.0f angle:360]];
}

@end
