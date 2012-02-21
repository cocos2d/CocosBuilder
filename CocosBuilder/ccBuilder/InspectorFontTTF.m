//
//  InspectorFontTTF.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFontTTF.h"

@implementation InspectorFontTTF

- (void) setFontName:(NSString *)fontName
{
    [self setPropertyForSelection:fontName];
}

- (NSString*) fontName
{
    return [self propertyForSelection];
}

@end
