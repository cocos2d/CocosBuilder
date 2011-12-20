//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class CocosBuilderAppDelegate;

@interface CCBGLView : MacGLView {
    
    NSTrackingRectTag trackingTag;
    
    IBOutlet CocosBuilderAppDelegate* appDelegate;
}

@end
