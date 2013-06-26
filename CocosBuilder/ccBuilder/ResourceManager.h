/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "SCEvents.h"
#import "SCEvent.h"

#define kCCBMaxTrackedDirectories 5000

enum
{
    kCCBResTypeNone,
    kCCBResTypeDirectory,
    kCCBResTypeSpriteSheet,
    kCCBResTypeAnimation,
    kCCBResTypeImage,
    kCCBResTypeBMFont,
    kCCBResTypeTTF,
    kCCBResTypeCCBFile,
    kCCBResTypeJS,
    kCCBResTypeJSON,
    kCCBResTypeAudio,
    kCCBResTypeGeneratedSpriteSheetDef,
};


@interface RMSpriteFrame : NSObject
{
    NSString* spriteSheetFile;
    NSString* spriteFrameName;
}
@property (nonatomic,retain) NSString* spriteSheetFile;
@property (nonatomic,retain) NSString* spriteFrameName;
@end


@interface RMAnimation : NSObject
{
    NSString* animationFile;
    NSString* animationName;
}
@property (nonatomic,retain) NSString* animationFile;
@property (nonatomic,retain) NSString* animationName;
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
- (NSImage*) preview;

@end


@interface RMDirectory : NSObject
{
    int count;
    NSString* dirPath;
    NSMutableDictionary* resources;
    BOOL isDynamicSpriteSheet;
    
    NSMutableArray* any;
    NSMutableArray* images;
    NSMutableArray* animations;
    NSMutableArray* bmFonts;
    NSMutableArray* ttfFonts;
    NSMutableArray* ccbFiles;
    NSMutableArray* audioFiles;
}

@property (nonatomic,assign) int count;
@property (nonatomic,retain) NSString* dirPath;
@property (nonatomic,readonly) NSMutableDictionary* resources;
@property (nonatomic,readonly) BOOL isDynamicSpriteSheet;

@property (nonatomic,readonly) NSMutableArray* any;
@property (nonatomic,readonly) NSMutableArray* images;
@property (nonatomic,readonly) NSMutableArray* animations;
@property (nonatomic,readonly) NSMutableArray* bmFonts;
@property (nonatomic,readonly) NSMutableArray* ttfFonts;
@property (nonatomic,readonly) NSMutableArray* ccbFiles;
@property (nonatomic,readonly) NSMutableArray* audioFiles;
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
    
    NSArray* systemFontList;
    
    BOOL tooManyDirectoriesAdded;
}

+ (ResourceManager*) sharedManager;

@property (nonatomic,readonly) NSMutableDictionary* directories;
@property (nonatomic,retain) NSArray* activeDirectories;
@property (nonatomic,readonly) NSString* mainActiveDirectoryPath;
@property (nonatomic,assign) BOOL tooManyDirectoriesAdded;

@property (nonatomic,readonly) NSArray* systemFontList;

- (void) addDirectory:(NSString*)dir;
- (void) removeDirectory:(NSString*)dir;
- (void) removeAllDirectories;

- (void) setActiveDirectory:(NSString *)dir;

- (void) addResourceObserver:(id)observer;
- (void) removeResourceObserver:(id)observer;

- (NSString*) toAbsolutePath:(NSString*)path;
- (NSArray*) resIndependentExts;
- (NSArray*) resIndependentDirs;

- (void) createCachedImageFromAuto:(NSString*)autoFile saveAs:(NSString*)dstFile forResolution:(NSString*)res;

- (void) notifyResourceObserversResourceListUpdated;

- (void) debugPrintDirectories;



@end
