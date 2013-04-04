//
//  DebuggerTextField.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/3/13.
//
//

#import "DebuggerTextField.h"

@implementation DebuggerTextField

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector: (SEL)aSelector
{
    return [self tryToPerform:aSelector with:aTextView];
}

- (void)moveUp:(id)sender
{
    NSLog(@"Increment by 1");
}

- (void)moveDown:(id)sender
{
}

- (void)dealloc
{
    [history release];
    [super dealloc];
}

@end
