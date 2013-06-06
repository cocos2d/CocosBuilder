//
//  CCBImageView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/5/13.
//
//

#import <Cocoa/Cocoa.h>

@interface CCBImageView : NSImageView
{
    NSString* imagePath;
}

@property (nonatomic,readonly) NSString* imagePath;

@end
