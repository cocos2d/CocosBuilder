//
//  PlugInManager.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class PlugInNode;

@interface PlugInManager : NSObject
{
    NSMutableDictionary* plugInsNode;
    NSMutableArray* plugInsNodeNames;
    NSMutableArray* plugInsNodeNamesCanBeRoot;
}

@property (nonatomic,readonly) NSMutableArray* plugInsNodeNames;
@property (nonatomic,readonly) NSMutableArray* plugInsNodeNamesCanBeRoot;

+ (PlugInManager*) sharedManager;
- (void) loadPlugIns;

- (PlugInNode*) plugInNodeNamed:(NSString*)name;
- (CCNode*) createDefaultNodeOfType:(NSString*)name;
@end
