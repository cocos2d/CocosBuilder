//
//  CCNode+NodeInfo.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCNode (NodeInfo)

@property BOOL seqExpanded;

- (id) extraPropForKey:(NSString*)key;
- (void) setExtraProp:(id)prop forKey:(NSString*)key;

@end
