//
//  ResourceManagerPreviewView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/3/13.
//
//

#import "ResourceManagerPreviewView.h"
#import "ResourceManager.h"
#import "CCBImageView.h"
#import "CocosBuilderAppDelegate.h"

@implementation ResourceManagerPreviewView

@synthesize previewMain;
@synthesize previewPhone;
@synthesize previewPhonehd;
@synthesize previewTablet;
@synthesize previewTablethd;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    // Disable focus rings
    [previewMain setFocusRingType:NSFocusRingTypeNone];
    [previewPhone setFocusRingType:NSFocusRingTypeNone];
    [previewPhonehd setFocusRingType:NSFocusRingTypeNone];
    [previewTablet setFocusRingType:NSFocusRingTypeNone];
    [previewTablethd setFocusRingType:NSFocusRingTypeNone];
}

- (void) setPreviewFile:(id) selection
{
    NSImage* preview = NULL;
    if ([selection respondsToSelector:@selector(preview)])
    {
        preview = [selection preview];
    }
    
    [previewMain setImage:preview];
    
    
    //if (preview) [lblNoPreview setHidden:YES];
    //else [lblNoPreview setHidden:NO];
}

- (IBAction)droppedFile:(id)sender
{
    if (![CocosBuilderAppDelegate appDelegate].projectSettings)
    {
        [self setPreviewFile:NULL];
        return;
    }
    
    CCBImageView* imgView = sender;
    
    NSLog(@"dropped file: %@", imgView.imagePath);
}

- (CocosBuilderAppDelegate*) appDelegate
{
    return [CocosBuilderAppDelegate appDelegate];
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 140) return 140;
    else return proposedMinimumPosition;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float max = splitView.frame.size.height - 100;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

@end
