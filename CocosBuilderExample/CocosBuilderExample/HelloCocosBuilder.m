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
