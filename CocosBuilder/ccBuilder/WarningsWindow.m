//
//  WarningsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WarningsWindow.h"

@implementation WarningsWindow

@synthesize warnings;

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
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    
    NSTableColumn* column = [[tableView tableColumns] objectAtIndex:0];
    NSTextFieldCell* cell = [column dataCellForRow:row];
    
    return [cell cellSizeForBounds:NSMakeRect(0, 0, tableView.bounds.size.width, 1024)].height;
}

@end
