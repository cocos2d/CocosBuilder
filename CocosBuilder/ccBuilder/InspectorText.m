//
//  InspectorText.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorText.h"

@implementation InspectorText

- (void) setText:(NSString *)text
{
    if (!text) text = @"";
    
    [self setPropertyForSelection:text];
}

- (NSString*) text
{
    return [self propertyForSelection];
}

@end
