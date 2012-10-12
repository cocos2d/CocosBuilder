/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "HelloCocosBuilder.h"
#import "CCBReader.h"
#import "CCBAnimationManager.h"
#import "TestAnimations.h"

@implementation HelloCocosBuilder

// This method is called right after the class has been instantiated
// by CCBReader. Do any additional initiation here. If no extra
// initialization is needed, leave this method out.
- (void) didLoadFromCCB
{    
    // Start rotating the burst sprite
    [sprtBurst runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:20.0f angle:360]]];
}

// Go to a new test scene
- (void) openTest:(NSString*)ccbFile
{
    // Load the scene from the ccbi-file, setting this class as
    // the owner will cause lblTestTitle to be set by the CCBReader.
    // lblTestTitle is in the TestHeader.ccbi, which is referenced
    // from each of the test scenes.
    CCScene* scene = [CCBReader sceneWithNodeGraphFromFile:ccbFile owner:self];
    
    // Set the title of the test to the same as the ccbi file's name
    [lblTestTitle setString:ccbFile];
    
    // Use a transition to go to the test scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:scene withColor:ccc3(0, 0, 0)]];
}

// Each of these methods are called when the buttons are pressed.
// The names of the methods are specified in the ccb-file.

- (void) pressedMenus:(id)sender
{
    [self openTest:@"TestMenus.ccbi"];
}

- (void) pressedSprites:(id)sender
{
    [self openTest:@"TestSprites.ccbi"];
}

- (void) pressedButtons:(id)sender
{
    [self openTest:@"TestButtons.ccbi"];
}

- (void) pressedAnimations:(id)sender
{
    [self openTest:@"TestAnimations.ccbi"];
}

- (void) pressedParticleSystems:(id)sender
{
    [self openTest:@"TestParticleSystems.ccbi"];
}

- (void) pressedScrollViews:(id)sender
{
    [self openTest:@"TestScrollViews.ccbi"];
}



@end
