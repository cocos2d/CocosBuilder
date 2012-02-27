//
//  PlugInExport.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlugInExport : NSObject
{
    NSBundle* bundle;
    NSString* extension;
    NSString* pluginName;
}

@property (nonatomic,readonly) NSString* extension;
@property (nonatomic,retain) NSString* pluginName;

- (id) initWithBundle:(NSBundle*) bundle;
- (NSData*) exportDocument:(NSDictionary*)doc;

@end