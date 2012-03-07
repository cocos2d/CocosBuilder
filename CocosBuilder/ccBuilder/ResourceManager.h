//
//  ResourceManager.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCEvents.h"
#import "SCEvent.h"

enum
{
    kCCBResTypeNone,
    kCCBResTypeDirectory,
    kCCBResTypeImage,
    kCCBResTypeSpriteSheet,
    kCCBResTypeBMFont
};


@interface RMSpriteFrame : NSObject
{
    NSString* spriteSheetFile;
    NSString* spriteFrameName;
}
@property (nonatomic,retain) NSString* spriteSheetFile;
@property (nonatomic,retain) NSString* spriteFrameName;
@end


@interface RMResource : NSObject
{
    int type;
    BOOL touched;
    NSString* filePath;
    NSDate* modifiedTime;
    id data;
}

@property (nonatomic,retain) NSString* filePath;
@property (nonatomic,retain) NSDate* modifiedTime;
@property (nonatomic,assign) int type;
@property (nonatomic,assign) BOOL touched;
@property (nonatomic,retain) id data;
- (void) loadData;

@end


@interface RMDirectory : NSObject
{
    int count;
    NSString* dirPath;
    NSMutableDictionary* resources;
    
    NSMutableArray* images;
}

@property (nonatomic,assign) int count;
@property (nonatomic,retain) NSString* dirPath;
@property (nonatomic,readonly) NSMutableDictionary* resources;
@property (nonatomic,readonly) NSMutableArray* images;

- (NSArray*) resourcesForType:(int)type;

@end


@interface ResourceManager : NSObject <SCEventListenerProtocol>
{
    NSMutableArray* resSpriteFrames;
    NSMutableArray* resBMFonts;
    
    NSMutableDictionary* directories;
    
    NSMutableArray* activeDirectories;
    
    SCEvents* pathWatcher;
    NSMutableArray* resourceObserver;
}

+ (ResourceManager*) sharedManager;

@property (nonatomic,readonly) NSMutableDictionary* directories;
@property (nonatomic,retain) NSArray* activeDirectories;

- (void) addDirectory:(NSString*)dir;
- (void) removeDirectory:(NSString*)dir;

- (void) setActiveDirectory:(NSString *)dir;

- (void) addResourceObserver:(id)observer;
- (void) removeResourceObserver:(id)observer;

@end
