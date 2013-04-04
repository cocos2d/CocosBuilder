//
//  DebuggerTextField.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/3/13.
//
//

#import "DebuggerTextField.h"

@implementation DebuggerTextField

- (void) additionalInitStuff
{
    history = [[NSMutableArray alloc] init];
    historyPosition = -1;
}

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return NULL;
    
    [self additionalInitStuff];
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return NULL;
    
    [self additionalInitStuff];
    
    return self;
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector: (SEL)aSelector
{
    return [self tryToPerform:aSelector with:aTextView];
}

- (void) addToHistory:(NSString*)script
{
    [history addObject:script];
    historyPosition = [history count];
}

- (void)moveUp:(id)sender
{
    historyPosition -= 1;
    if (historyPosition < 0)
    {
        historyPosition = 0;
        return;
    }
    
    [self setStringValue:[history objectAtIndex:historyPosition]];
    
    NSLog(@"setStringValue: %@ pos: %d", [history objectAtIndex:historyPosition], historyPosition);
    
}

- (void)moveDown:(id)sender
{
    historyPosition += 1;
    
    if (historyPosition >= [history count])
    {
        [self setStringValue:@""];
        historyPosition = [history count];
        return;
    }
    
    [self setStringValue:[history objectAtIndex:historyPosition]];
    
    
    NSLog(@"setStringValue: %@ pos: %D", [history objectAtIndex:historyPosition], historyPosition);
}

- (void)dealloc
{
    [history release];
    [super dealloc];
}

@end
