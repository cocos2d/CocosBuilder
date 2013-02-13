//
//  SequencerPopoverHandler.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/12/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SequencerPopoverHandler : NSViewController

+ (void) popoverNode:(CCNode*) node property: (NSString*) prop overView:(NSView*) parent kfBounds:(NSRect) kfBounds;

@end
