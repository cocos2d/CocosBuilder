//
//  InspectorBlock.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorBlock : InspectorValue

@property (nonatomic,assign) NSString* selector;
@property (nonatomic,assign) int target;

@end
