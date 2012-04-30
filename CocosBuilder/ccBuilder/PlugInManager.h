/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class PlugInNode;
@class PlugInExport;

@interface PlugInManager : NSObject
{
#if !CCB_BUILDING_COMMANDLINE
    NSMutableDictionary* plugInsNode;
    NSMutableArray* plugInsNodeNames;
    NSMutableArray* plugInsNodeNamesCanBeRoot;
#endif
	
    NSMutableArray* plugInsExporters;
}

#if !CCB_BUILDING_COMMANDLINE
@property (nonatomic,readonly) NSMutableArray* plugInsNodeNames;
@property (nonatomic,readonly) NSMutableArray* plugInsNodeNamesCanBeRoot;
#endif

@property (nonatomic,retain) NSMutableArray* plugInsExporters;

+ (PlugInManager*) sharedManager;
- (void) loadPlugIns;

#if !CCB_BUILDING_COMMANDLINE
// Plug-in node
- (PlugInNode*) plugInNodeNamed:(NSString*)name;
- (CCNode*) createDefaultNodeOfType:(NSString*)name;
#endif

// Plug-in export
- (NSArray*) plugInsExportNames;
- (PlugInExport*) plugInExportForIndex:(int)idx;
- (PlugInExport*) plugInExportForExtension:(NSString*)ext;
@end
