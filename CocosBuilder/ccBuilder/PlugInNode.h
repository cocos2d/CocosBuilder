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
    
    NSMutableArray* nodeProperties;
}

@property (nonatomic,readonly) NSString* nodeClassName;
@property (nonatomic,readonly) NSMutableArray* nodeProperties;

- (id) initWithBundle:(NSBundle*) b;

@end
