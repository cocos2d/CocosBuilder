//
//  HelloCocosBuilder.h
//  CocosBuilderTest
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// This is a custom class for a layer specified by setting the custom
// class attribute in CocosBuilder for the root node.
// It is loaded from AppDelegate.m

@interface HelloCocosBuilder : CCLayer
{
    
    // These instance variables are defined in the CocosBuilder file
    // (example.ccb) and automatically assigned by CCBReader
    CCSprite* sprtBurst;
    CCSprite* sprtIcon;
}

@end
