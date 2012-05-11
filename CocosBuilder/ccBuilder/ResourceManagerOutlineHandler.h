//
//  ResourceManagerOutlineHandler.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResourceManager;

@interface ResourceManagerOutlineHandler : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    ResourceManager* resManager;
    NSOutlineView* resourceList;
    IBOutlet NSImageView* imagePreview;
    IBOutlet NSTextField* lblNoPreview;
    int resType;
}

@property (nonatomic,assign) int resType;

- (id) initWithOutlineView:(NSOutlineView *)outlineView resType:(int)rt;

- (id) initWithOutlineView:(NSOutlineView*)outlineView resType:(int)rt imagePreview:(NSImageView*)preview lblNoPreview:(NSTextField*)lbl;

- (void) reload;

@end
