//
//  HelpPage.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpPage.h"

@implementation HelpPage

@synthesize fileName;
@synthesize contents;

- (NSString*) pageName
{
    return [fileName stringByDeletingPathExtension];
}

- (void) dealloc
{
    self.fileName = NULL;
    self.contents = NULL;
    [super dealloc];
}

@end
