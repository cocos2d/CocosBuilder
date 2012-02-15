//
//  InspectorCodeConnections.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorCodeConnections : InspectorValue

@property (nonatomic,assign) NSString* customClass;
@property (nonatomic,assign) NSString* memberVarAssignmentName;
@property (nonatomic,assign) int memberVarAssignmentType;

@end
