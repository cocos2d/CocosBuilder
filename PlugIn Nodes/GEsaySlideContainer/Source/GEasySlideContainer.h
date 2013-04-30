//
//  GEasySlideContainer.h
//  GEasySlideContainer
//
//  Created by GuoDong on 12-12-29.
//
//

#import "cocos2d.h"

typedef enum
{
    kSlideDirection_Horizental,
    kSlideDirection_Vertical,
    kSlideDirection_Any
}ESlideDirection;

@interface GEasySlideContainer : CCLayer
{
    ESlideDirection direction;
}
@property(readwrite,nonatomic,assign)ESlideDirection direction;
@end
