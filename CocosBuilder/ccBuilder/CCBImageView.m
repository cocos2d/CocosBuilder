/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
