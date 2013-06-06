//
//  CCBImageView.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/5/13.
//
//

#import "CCBImageView.h"

@implementation CCBImageView

@synthesize imagePath;

/*
- (void)setImage:(NSImage *)image
{
    [image setName:[[imagePath lastPathComponent] stringByDeletingPathExtension]];
    [super setImage:image];
}
*/

- (BOOL)performDragOperation:(id )sender
{
    BOOL dragSucceeded = [super performDragOperation:sender];
    if (dragSucceeded) {
        NSString *filenamesXML = [[sender draggingPasteboard] stringForType:NSFilenamesPboardType];
        if (filenamesXML) {
            NSArray *filenames = [NSPropertyListSerialization
                                  propertyListFromData:[filenamesXML dataUsingEncoding:NSUTF8StringEncoding]
                                  mutabilityOption:NSPropertyListImmutable
                                  format:nil
                                  errorDescription:nil];
            if ([filenames count] >= 1) {
                imagePath = [filenames objectAtIndex:0];
            } else {
                imagePath = nil;
            }
        }
    }
    return dragSucceeded;
}

@end
