//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
//#import "IKImageBrowserView.h"
//#import <Quartz/ImageKit.h>
//#import <Quartz/IKImageBrowserView.h>

@interface AssetsWindowController : NSWindowController
{
    IBOutlet IKImageBrowserView* imageBrowser;
    NSMutableArray* assetsItems;
    NSMutableArray* spriteSheetList;
    
    NSMutableArray* browserGroups;
    NSUInteger imagesVersion;
}

@property (nonatomic, retain) NSMutableArray* spriteSheetList;

- (void) clearContents;
- (void) addImage:(NSString*) imageFile;
- (void) addSpriteSheet:(NSString*) spriteSheetFile;
- (void) reloadData;
- (void) invalidateImageCache;

@end
