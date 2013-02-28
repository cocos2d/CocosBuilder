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

#import "PlayerStatusLayer.h"
#import "CCBReader.h"
#import "AppDelegate.h"
#import "ServerController.h"

static PlayerStatusLayer* sharedPlayerStatusLayer = NULL;

@implementation PlayerStatusLayer

@synthesize lblInstructions, lblStatus, lblPair;

+ (PlayerStatusLayer*) sharedInstance
{
    return sharedPlayerStatusLayer;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerStatusLayer = self;
    
    return self;
}

- (void) updatePairingLabel
{
    NSString* pairing = [[NSUserDefaults standardUserDefaults] objectForKey:@"pairing"];
    
    if (!pairing) pairing = @"Auto";
    lblPair.string = pairing;
	
	// disabled on iOS 4 because the pair code requires iOS 5
	if( [[CCConfiguration sharedConfiguration] OSVersion] < kCCiOSVersion_5_0)
		btnPair.isEnabled = NO;
}

- (void) didLoadFromCCB
{
    [lblStatus setString:kCCBNetworkStatusStringWaiting];
    [self updatePairingLabel];
	
}

- (void) onEnter
{
    [super onEnter];
    
    // Update status of buttons
    
    // Enable Run & Reset btn if main.js exists
    NSString* mainJSPath = [[CCBReader ccbDirectoryPath] stringByAppendingPathComponent:@"main.js"];
    BOOL mainExist = [[NSFileManager defaultManager] fileExistsAtPath:mainJSPath];
    btnRun.isEnabled = mainExist;
    btnReset.isEnabled = mainExist;
}

- (void) pressedRun:(id)sender
{
    [[AppController appController] runJSApp];
}

- (void) pressedReset:(id)sender
{
    // Remove the ccb directory
    [[NSFileManager defaultManager] removeItemAtPath:[CCBReader ccbDirectoryPath] error:NULL];
    
    btnRun.isEnabled = NO;
    btnReset.isEnabled = NO;
    
    [[AppController appController].server sendFileList];
}

- (void) pressedPair:(id)sender
{
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Pair Device" message:@"Enter a 4 digit pairing number (use the same number in CocosBuilder)" delegate:self cancelButtonTitle:@"Remove" otherButtonTitles:@"Set Pairing", nil] autorelease];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField* textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* pairing = NULL;
    if (buttonIndex == 1)
    {
        UITextField* textField = [alertView textFieldAtIndex:0];
        pairing = textField.text;
        if ([pairing isEqualToString:@""]) pairing = NULL;
    }
    
    if (pairing)
    {
        [[NSUserDefaults standardUserDefaults] setObject:pairing forKey:@"pairing"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pairing"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updatePairingLabel];
    [[AppController appController] updatePairing];
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    // Validate string length
    NSUInteger newLength = [theTextField.text length] + [string length] - range.length;
    if (newLength > 4) return NO;
    
    // Make sure it only uses numbers
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    
    return YES;
}

@end
