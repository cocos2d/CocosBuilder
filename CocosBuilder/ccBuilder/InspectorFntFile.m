//
//  InspectorFntFile.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorFntFile.h"
#import "TexturePropertySetter.h"

@implementation InspectorFntFile

- (void) setFntFile:(NSString *)fntFile
{
    [TexturePropertySetter setFontForNode:selection andProperty:propertyName withFile:fntFile];
    
    [self updateAffectedProperties];
}

- (NSString*) fntFile
{
    return [TexturePropertySetter fontForNode:selection andProperty:propertyName];
}

@end
