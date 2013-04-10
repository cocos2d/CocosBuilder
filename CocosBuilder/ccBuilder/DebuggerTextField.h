//
//  DebuggerTextField.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/3/13.
//
//

#import "CCBTextField.h"

@interface DebuggerTextField : CCBTextField
{
    int historyPosition;
    NSMutableArray* history;
}

- (void) addToHistory:(NSString*)script;

@end
