//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CCBTemplate;

@interface EditTemplateWindowController : NSWindowController
{
    CCBTemplate* temp;
    
    NSArray* pListFiles;
    NSArray* imgFiles;
    
    NSString* customClass;
    NSString* propertyFile;
    NSString* previewImage;
    NSNumber* xPreviewAnchorpoint;
    NSNumber* yPreviewAnchorpoint;
    
    BOOL canCreatePropertyFile;
}

@property (nonatomic,retain) NSArray* pListFiles;
@property (nonatomic,retain) NSArray* imgFiles;

@property (nonatomic,retain) NSString* customClass;
@property (nonatomic,retain) NSString* propertyFile;
@property (nonatomic,retain) NSString* previewImage;
@property (nonatomic,retain) NSNumber* xPreviewAnchorpoint;
@property (nonatomic,retain) NSNumber* yPreviewAnchorpoint;

@property (nonatomic,assign) BOOL canCreatePropertyFile;

- (void)popuplateWithTemplate:(CCBTemplate*)t;

@end
