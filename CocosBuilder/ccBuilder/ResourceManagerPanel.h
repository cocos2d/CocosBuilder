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
    
    ResourceManager* resManager;
    int resType;
}

@property (nonatomic,readonly) ResourceManager* resManager;

- (void) reload;

@end
