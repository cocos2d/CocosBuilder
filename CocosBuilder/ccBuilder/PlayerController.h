//
//  PlayerController.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProjectSettings;

@interface PlayerController : NSObject

- (void) runPlayerForProject:(ProjectSettings*)ps;

@end
