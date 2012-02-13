//
//  NodeInfo.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlugInNode;

@interface NodeInfo : NSObject
{
    PlugInNode* plugIn;
    NSMutableDictionary* extraProps;
}

@property (nonatomic,assign) PlugInNode* plugIn;
@property (nonatomic,readonly) NSMutableDictionary* extraProps;

+ (id) nodeInfoWithPlugIn:(PlugInNode*)pin;

@end
