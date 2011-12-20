//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface TemplateWindowController : NSWindowController
{
    IBOutlet IKImageBrowserView* imageBrowser;
    NSMutableArray* templateFiles;
    NSUInteger imagesVersion;
}

@property (nonatomic,retain) NSMutableArray* templateFiles;

//- (void) clearContents;

- (void) reloadData;

@end
