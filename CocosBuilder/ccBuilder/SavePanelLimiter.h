//
//  SavePanelLimiter.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResourceManager;

@interface SavePanelLimiter : NSObject <NSOpenSavePanelDelegate>
{
    ResourceManager* resManager;
}

- (id) initWithPanel:(NSSavePanel*)savePanel resManager:(ResourceManager*)rm;

@end
