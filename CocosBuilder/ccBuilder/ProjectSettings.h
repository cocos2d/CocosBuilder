//
//  ProjectSettings.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectSettings : NSObject
{
    NSString* projectPath;
    NSMutableArray* resourcePaths;
    NSString* publishDirectory;
    BOOL flattenPaths;
    BOOL publishToZipFile;
}

@property (nonatomic, copy) NSString* projectPath;
@property (nonatomic, retain) NSMutableArray* resourcePaths;
@property (nonatomic, copy) NSString* publishDirectory;
@property (nonatomic, assign) BOOL flattenPaths;
@property (nonatomic, assign) BOOL publishToZipFile;

@end
