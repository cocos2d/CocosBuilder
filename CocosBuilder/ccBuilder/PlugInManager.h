//
//  PlugInManager.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlugInManager : NSObject
{
    NSMutableDictionary* plugInsNode;
}

+ (PlugInManager*) sharedManager;
- (void) loadPlugIns;
@end
