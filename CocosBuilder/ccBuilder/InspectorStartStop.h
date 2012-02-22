//
//  InspectorStartStop.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorStartStop : InspectorValue
{
    NSString* startName;
    NSString* stopName;
    
    NSString* startMethod;
    NSString* stopMethod;
}

@property (nonatomic,assign) NSString* startName;
@property (nonatomic,assign) NSString* stopName;

- (IBAction)pressedStart:(id)sender;
- (IBAction)pressedStop:(id)sender;

@end
