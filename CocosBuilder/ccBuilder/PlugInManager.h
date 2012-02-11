//
//  PlugInManager.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlugInNode;

@interface PlugInManager : NSObject
{
    NSMutableDictionary* plugInsNode;
    NSMutableArray* plugInsNodeNames;
}

@property (nonatomic,readonly) NSMutableArray* plugInsNodeNames;

+ (PlugInManager*) sharedManager;
- (void) loadPlugIns;

- (PlugInNode*) plugInNodeNamed:(NSString*)name;

@end
