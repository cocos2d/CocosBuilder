//
//  PlayerConsolePairingWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBModalSheetController.h"

@interface PlayerConsolePairingWindow : CCBModalSheetController
{
    int pairing;
}

@property (nonatomic,assign) int pairing;

@end
