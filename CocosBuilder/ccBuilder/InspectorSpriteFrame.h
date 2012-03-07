//
//  InspectorTexture.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InspectorValue.h"

@interface InspectorSpriteFrame : InspectorValue
{
    //NSMutableArray* assetsImgList;
    //BOOL isSetSpriteSheet;
    
    IBOutlet NSPopUpButton* popup;
    IBOutlet NSMenu* menu;
}

//@property (nonatomic,retain) NSMutableArray* assetsImgList;

//@property (nonatomic,assign) NSString* spriteFile;
//@property (nonatomic,assign) NSString* spriteSheetFile;

@end
