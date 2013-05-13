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

#define kCCBProjectSettingsVersion 1
#define kCCBDefaultExportPlugIn @"ccbi"

@class RMResource;

@interface ProjectSettingsGeneratedSpriteSheet : NSObject
{
    BOOL isDirty;
    int textureFileFormat;
    BOOL dither;
    BOOL compress;
    int textureFileFormatAndroid;
    BOOL ditherAndroid;
    int textureFileFormatHTML5;
    BOOL ditherHTML5;
}
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) int textureFileFormat;
@property (nonatomic,assign) BOOL dither;
@property (nonatomic,assign) BOOL compress;
@property (nonatomic,assign) int textureFileFormatAndroid;
@property (nonatomic,assign) BOOL ditherAndroid;
@property (nonatomic,assign) int textureFileFormatHTML5;
@property (nonatomic,assign) BOOL ditherHTML5;

- (id)initWithSerialization:(id)dict;
- (id)serialize;
@end

@interface ProjectSettings : NSObject
{
    NSString* projectPath;
    NSMutableArray* resourcePaths;
    NSMutableDictionary* generatedSpriteSheets;
    NSMutableDictionary* breakpoints;
    
    NSString* publishDirectory;
    NSString* publishDirectoryAndroid;
    NSString* publishDirectoryHTML5;
    
    BOOL publishEnablediPhone;
    BOOL publishEnabledAndroid;
    BOOL publishEnabledHTML5;
    
    BOOL publishResolution_;
    BOOL publishResolution_hd;
    BOOL publishResolution_ipad;
    BOOL publishResolution_ipadhd;
    BOOL publishResolution_xsmall;
    BOOL publishResolution_small;
    BOOL publishResolution_medium;
    BOOL publishResolution_large;
    BOOL publishResolution_xlarge;
    
    int publishResolutionHTML5_width;
    int publishResolutionHTML5_height;
    int publishResolutionHTML5_scale;
    
    BOOL isSafariExist;
    BOOL isChromeExist;
    BOOL isFirefoxExist;
    
    BOOL flattenPaths;
    BOOL publishToZipFile;
    BOOL javascriptBased;
    BOOL onlyPublishCCBs;
    NSString* exporter;
    NSMutableArray* availableExporters;
    NSString* javascriptMainCCB;
    BOOL deviceOrientationPortrait;
    BOOL deviceOrientationUpsideDown;
    BOOL deviceOrientationLandscapeLeft;
    BOOL deviceOrientationLandscapeRight;
    int resourceAutoScaleFactor;
    
    NSString* versionStr;
    BOOL needRepublish;
}

@property (nonatomic, copy) NSString* projectPath;
@property (nonatomic, readonly) NSString* projectPathHashed;
@property (nonatomic, retain) NSMutableArray* resourcePaths;

@property (nonatomic,assign) BOOL publishEnablediPhone;
@property (nonatomic,assign) BOOL publishEnabledAndroid;
@property (nonatomic,assign) BOOL publishEnabledHTML5;

@property (nonatomic, copy) NSString* publishDirectory;
@property (nonatomic, copy) NSString* publishDirectoryAndroid;
@property (nonatomic, copy) NSString* publishDirectoryHTML5;

@property (nonatomic,assign) BOOL publishResolution_;
@property (nonatomic,assign) BOOL publishResolution_hd;
@property (nonatomic,assign) BOOL publishResolution_ipad;
@property (nonatomic,assign) BOOL publishResolution_ipadhd;
@property (nonatomic,assign) BOOL publishResolution_xsmall;
@property (nonatomic,assign) BOOL publishResolution_small;
@property (nonatomic,assign) BOOL publishResolution_medium;
@property (nonatomic,assign) BOOL publishResolution_large;
@property (nonatomic,assign) BOOL publishResolution_xlarge;

@property (nonatomic,assign) int publishResolutionHTML5_width;
@property (nonatomic,assign) int publishResolutionHTML5_height;
@property (nonatomic,assign) int publishResolutionHTML5_scale;

@property (nonatomic,assign) BOOL isSafariExist;
@property (nonatomic,assign) BOOL isChromeExist;
@property (nonatomic,assign) BOOL isFirefoxExist;

@property (nonatomic, copy) NSString* javascriptMainCCB;
@property (nonatomic, assign) BOOL flattenPaths;
@property (nonatomic, assign) BOOL publishToZipFile;
@property (nonatomic, assign) BOOL javascriptBased;
@property (nonatomic, assign) BOOL onlyPublishCCBs;
@property (nonatomic, readonly) NSArray* absoluteResourcePaths;
@property (nonatomic, copy) NSString* exporter;
@property (nonatomic, retain) NSMutableArray* availableExporters;
@property (nonatomic, readonly) NSString* displayCacheDirectory;
@property (nonatomic, readonly) NSString* publishCacheDirectory;
@property (nonatomic, readonly) NSString* tempSpriteSheetCacheDirectory;
@property (nonatomic, assign) BOOL deviceOrientationPortrait;
@property (nonatomic, assign) BOOL deviceOrientationUpsideDown;
@property (nonatomic, assign) BOOL deviceOrientationLandscapeLeft;
@property (nonatomic, assign) BOOL deviceOrientationLandscapeRight;
@property (nonatomic, assign) int resourceAutoScaleFactor;

@property (nonatomic, readonly) NSDictionary* generatedSpriteSheets;

@property (nonatomic,readonly) NSDictionary* breakpoints;
@property (nonatomic, copy) NSString* versionStr;
@property (nonatomic, assign) BOOL needRepublish;

- (id) initWithSerialization:(id)dict;
- (BOOL) store;
- (id) serialize;

- (void) makeSmartSpriteSheet:(RMResource*) res;
- (void) removeSmartSpriteSheet:(RMResource*) res;
- (ProjectSettingsGeneratedSpriteSheet*) smartSpriteSheetForRes:(RMResource*) res;
- (ProjectSettingsGeneratedSpriteSheet*) smartSpriteSheetForSubPath:(NSString*) relPath;

- (void) toggleBreakpointForFile:(NSString*)file onLine:(int)line;
- (NSSet*) breakpointsForFile:(NSString*)file;
@end
