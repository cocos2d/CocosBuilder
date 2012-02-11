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
}

@property (nonatomic,assign) PlugInNode* plugIn;

@end
