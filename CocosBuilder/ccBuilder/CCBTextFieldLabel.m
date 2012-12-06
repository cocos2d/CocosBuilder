//
//  CCBTextFieldLabel.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 10/31/12.
//
//

#import "CCBTextFieldLabel.h"

@implementation CCBTextFieldLabel

- (void) setEnabled: (BOOL) flag
{
    [super setEnabled: flag];
    
    if (flag == NO) {
        [self setTextColor: [NSColor disabledControlTextColor]];
    } else {
        [self setTextColor: [NSColor controlTextColor]];
    }
    
}

@end
