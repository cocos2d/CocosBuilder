//
//  InspectorIntegerLabeled.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorIntegerLabeled : InspectorValue
{
    IBOutlet NSPopUpButton* popup;
    IBOutlet NSMenu* menu;
}

@property (nonatomic,assign) int selectedTag;

@end
