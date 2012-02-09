//
//  PlugInNode.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBP.h"

@interface PlugInNode : NSObject
{
    NSBundle* bundle;
    id<CCBP> instance;
    
    NSString* nodeClassName;
}

@property (nonatomic,readonly) NSString* nodeClassName;

- (id) initWithBundle:(NSBundle*) b;

@end
