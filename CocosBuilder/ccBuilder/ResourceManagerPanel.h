//
//  ResourceManagerPanel.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ResourceManager;

@interface ResourceManagerPanel : NSWindowController<NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    IBOutlet NSOutlineView* resourceList;
    IBOutlet NSImageView* imagePreview;
    IBOutlet NSTextField* lblNoPreview;
    
    
    ResourceManager* resManager;
    int resType;
}

@property (nonatomic,readonly) ResourceManager* resManager;

@property (nonatomic,assign) int resType;

- (void) reload;

@end
