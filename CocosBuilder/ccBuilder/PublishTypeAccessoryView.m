//
//  PublishTypeAccessoryView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PublishTypeAccessoryView.h"
#import "PlugInManager.h"
#import "PlugInExport.h"

@implementation PublishTypeAccessoryView

@synthesize exporterNames, selectedIndex,savePanel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return NULL;
    
    self.exporterNames = [[PlugInManager sharedManager] plugInsExportNames];
    
    return self;
}

- (void) setSelectedIndex:(int)idx
{
    selectedIndex = idx;
    
    NSLog(@"setSelectedIndex: %d",idx);
    
    NSString* type = [[[PlugInManager sharedManager] plugInExportForIndex:idx] extension];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:type]];
}

- (void) dealloc
{
    self.exporterNames = NULL;
    [super dealloc];
}

@end
