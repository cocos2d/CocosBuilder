//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCBModalSheetController.h"

@interface StageSizeWindow : CCBModalSheetController
{   
    int wStage;
    int hStage;
}

@property (nonatomic,assign) int wStage;
@property (nonatomic,assign) int hStage;

@end
