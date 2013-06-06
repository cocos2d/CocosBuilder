//
//  ResourceManagerPreviewView.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/3/13.
//
//

#import <Foundation/Foundation.h>

@class CCBImageView;
@class CocosBuilderAppDelegate;

@interface ResourceManagerPreviewView : NSObject <NSSplitViewDelegate>
{
    IBOutlet CCBImageView* previewMain;
    IBOutlet CCBImageView* previewPhone;
    IBOutlet CCBImageView* previewPhonehd;
    IBOutlet CCBImageView* previewTablet;
    IBOutlet CCBImageView* previewTablethd;
}
@property (nonatomic,readonly) IBOutlet CCBImageView* previewMain;
@property (nonatomic,readonly) IBOutlet CCBImageView* previewPhone;
@property (nonatomic,readonly) IBOutlet CCBImageView* previewPhonehd;
@property (nonatomic,readonly) IBOutlet CCBImageView* previewTablet;
@property (nonatomic,readonly) IBOutlet CCBImageView* previewTablethd;
@property (nonatomic,readonly) CocosBuilderAppDelegate* appDelegate;

- (void) setPreviewFile:(NSString*) file;

@end
