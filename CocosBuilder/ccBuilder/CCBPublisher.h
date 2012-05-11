//
//  CCBPublisher.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectSettings;
@class CCBWarnings;

@interface CCBPublisher : NSObject
{
    ProjectSettings* projectSettings;
    CCBWarnings* warnings;
    NSString* outputDir;
    NSArray* copyExtensions;
    NSString* publishFormat;
}

@property (nonatomic,copy) NSString* publishFormat;

- (id) initWithProjectSettings:(ProjectSettings*)settings warnings:(CCBWarnings*)w;
- (BOOL) publish;

@end
