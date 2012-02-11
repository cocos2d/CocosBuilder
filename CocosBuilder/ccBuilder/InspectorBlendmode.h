//
//  InspectorBlendmode.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorBlendmode : InspectorValue

@property (nonatomic,assign) int blendSrc;
@property (nonatomic,assign) int blendDst;

- (IBAction)blendNormal:(id)sender;
- (IBAction)blendAdditive:(id)sender;

@end
