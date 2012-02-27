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
@class PlugInExport;

@interface PlugInManager : NSObject
{
    NSMutableDictionary* plugInsNode;
    NSMutableArray* plugInsNodeNames;
    NSMutableArray* plugInsNodeNamesCanBeRoot;
    
    NSMutableArray* plugInsExporters;
}

@property (nonatomic,readonly) NSMutableArray* plugInsNodeNames;
@property (nonatomic,readonly) NSMutableArray* plugInsNodeNamesCanBeRoot;
@property (nonatomic,retain) NSMutableArray* plugInsExporters;

+ (PlugInManager*) sharedManager;
- (void) loadPlugIns;

// Plug-in node
- (PlugInNode*) plugInNodeNamed:(NSString*)name;
- (CCNode*) createDefaultNodeOfType:(NSString*)name;

// Plug-in export
- (NSArray*) plugInsExportNames;
- (PlugInExport*) plugInExportForIndex:(int)idx;
- (PlugInExport*) plugInExportForExtension:(NSString*)ext;
@end
