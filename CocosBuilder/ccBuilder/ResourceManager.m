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

#import "ResourceManager.h"
#import "CCBSpriteSheetParser.h"
#import "CCBAnimationParser.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"

#pragma mark RMSpriteFrame

@implementation RMSpriteFrame

@synthesize spriteFrameName, spriteSheetFile;

- (void) dealloc
{
    self.spriteFrameName = NULL;
    self.spriteSheetFile = NULL;
    [super dealloc];
}

- (NSImage*) preview
{
    return [CCBSpriteSheetParser imageNamed:spriteFrameName fromSheet:spriteSheetFile];
}

@end


#pragma mark RMAnimation

@implementation RMAnimation

@synthesize animationFile, animationName;

- (void) dealloc
{
    self.animationFile = NULL;
    self.animationName = NULL;
    [super dealloc];
}

@end


#pragma mark RMResource

@implementation RMResource

@synthesize type, modifiedTime, touched, data, filePath;

- (void) loadData
{
    if (type == kCCBResTypeSpriteSheet)
    {
        NSArray* spriteFrameNames = [CCBSpriteSheetParser listFramesInSheet:filePath];
        NSMutableArray* spriteFrames = [NSMutableArray arrayWithCapacity:[spriteFrameNames count]];
        for (NSString* frameName in spriteFrameNames)
        {
            RMSpriteFrame* frame = [[[RMSpriteFrame alloc] init] autorelease];
            frame.spriteFrameName = frameName;
            frame.spriteSheetFile = self.filePath;
            
            [spriteFrames addObject:frame];
        }
        self.data = spriteFrames;
    }
    else if (type == kCCBResTypeAnimation)
    {
        NSArray* animationNames = [CCBAnimationParser listAnimationsInFile:filePath];
        NSMutableArray* animations = [NSMutableArray arrayWithCapacity:[animationNames count]];
        for (NSString* animationName in animationNames)
        {
            RMAnimation* anim = [[[RMAnimation alloc] init] autorelease];
            anim.animationName = animationName;
            anim.animationFile = self.filePath;
            
            [animations addObject:anim];
        }
        self.data = animations;
    }
    else if (type == kCCBResTypeDirectory)
    {
        // Ignore changed directories
    }
    else
    {
        self.data = NULL;
    }
}

- (NSImage*) preview
{
    if (type == kCCBResTypeImage)
    {
        NSImage* img = [[[NSImage alloc] initWithContentsOfFile:filePath] autorelease];
        return img;
    }
    
    return NULL;
}

- (NSComparisonResult) compare:(id) obj
{
    RMResource* res = obj;
    
    if (res.type < self.type)
    {
        return NSOrderedDescending;
    }
    else if (res.type > self.type)
    {
        return NSOrderedAscending;
    }
    else
    {
        return [[self.filePath lastPathComponent] compare:[res.filePath lastPathComponent] options:NSNumericSearch|NSForcedOrderingSearch|NSCaseInsensitiveSearch];
    }
}

- (void) dealloc
{
    self.data = NULL;
    self.modifiedTime = NULL;
    self.filePath = NULL;
    [super dealloc];
}

@end


#pragma mark RMDirectory

@implementation RMDirectory

@synthesize count,dirPath, resources, images, animations, bmFonts, ttfFonts, ccbFiles;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    resources = [[NSMutableDictionary alloc] init];
    images = [[NSMutableArray alloc] init];
    animations = [[NSMutableArray alloc] init];
    bmFonts = [[NSMutableArray alloc] init];
    ttfFonts = [[NSMutableArray alloc] init];
    ccbFiles = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSArray*)resourcesForType:(int)type
{
    if (type == kCCBResTypeImage) return images;
    if (type == kCCBResTypeBMFont) return bmFonts;
    if (type == kCCBResTypeTTF) return ttfFonts;
    if (type == kCCBResTypeAnimation) return animations;
    if (type == kCCBResTypeCCBFile) return ccbFiles;
    return NULL;
}

- (void) dealloc
{
    [resources release];
    [images release];
    [animations release];
    [bmFonts release];
    [ttfFonts release];
    [ccbFiles release];
    self.dirPath = NULL;
    [super dealloc];
}

- (NSComparisonResult) compare:(RMDirectory*)dir
{
    return [dirPath compare:dir.dirPath];
}

@end


#pragma mark ResourceManager

@implementation ResourceManager

@synthesize directories, activeDirectories, systemFontList;

+ (ResourceManager*) sharedManager
{
    static ResourceManager* rm = NULL;
    if (!rm) rm = [[ResourceManager alloc] init];
    return rm;
}

- (void) loadFontListTTF
{
    NSMutableDictionary* fontInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FontListTTF" ofType:@"plist"]];
    systemFontList = [fontInfo objectForKey:@"supportedFonts"];
    [systemFontList retain];
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    directories = [[NSMutableDictionary alloc] init];
    activeDirectories = [[NSMutableArray alloc] init];
    pathWatcher = [[SCEvents alloc] init];
    pathWatcher.ignoreEventsFromSubDirs = YES;
    pathWatcher.delegate = self;
    resourceObserver = [[NSMutableArray alloc] init];
    
    [self loadFontListTTF];
    
    return self;
}

- (void) dealloc
{
    [pathWatcher release];
    [directories release];
    [activeDirectories release];
    [resourceObserver release];
    [systemFontList release];
    self.activeDirectories = NULL;
    [super dealloc];
}

- (NSArray*) getAddedDirs
{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:[directories count]];
    for (NSString* dirPath in directories)
    {        
        [arr addObject:dirPath];
    }
    return arr;
}



- (void) updatedWatchedPaths
{
    if (pathWatcher.isWatchingPaths)
    {
        [pathWatcher stopWatchingPaths];
    }
    [pathWatcher startWatchingPaths:[self getAddedDirs]];
}

- (void) notifyResourceObserversResourceListUpdated
{
    for (id observer in resourceObserver)
    {
        if ([observer respondsToSelector:@selector(resourceListUpdated)])
        {
            [observer performSelector:@selector(resourceListUpdated)];
        }
    }
}

- (int) getResourceTypeForFile:(NSString*) file
{
    NSString* ext = [[file pathExtension] lowercaseString];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    [fm fileExistsAtPath:file isDirectory:&isDirectory];
    
    if (isDirectory)
    {
        return kCCBResTypeDirectory;
    }
    else if ([[file stringByDeletingPathExtension] hasSuffix:@"-hd"]
             || [[file stringByDeletingPathExtension] hasSuffix:@"@2x"])
    {
        // Ignore -hd files
        return kCCBResTypeNone;
    }
    else if ([ext isEqualToString:@"png"]
        || [ext isEqualToString:@"jpg"]
        || [ext isEqualToString:@"jpeg"])
    {
        return kCCBResTypeImage;
    }
    else if ([ext isEqualToString:@"fnt"])
    {
        return kCCBResTypeBMFont;
    }
    else if ([ext isEqualToString:@"ttf"])
    {
        return kCCBResTypeTTF;
    }
    else if ([ext isEqualToString:@"plist"]
             && [CCBSpriteSheetParser isSpriteSheetFile:file])
    {
        return kCCBResTypeSpriteSheet;
    }
    else if ([ext isEqualToString:@"plist"]
             && [CCBAnimationParser isAnimationFile:file])
    {
        return kCCBResTypeAnimation;
    }
    else if ([ext isEqualToString:@"ccb"])
    {
        return kCCBResTypeCCBFile;
    }
    
    return kCCBResTypeNone;
}

- (void) clearTouchedForResInDir:(RMDirectory*)dir
{
    NSDictionary* resources = dir.resources;
    for (NSString* file in resources)
    {
        RMResource* res = [resources objectForKey:file];
        res.touched = NO;
    }
}

- (void) updateResourcesForPath:(NSString*) path
{
    NSFileManager* fm = [NSFileManager defaultManager];
    RMDirectory* dir = [directories objectForKey:path];
    NSArray* files = [fm contentsOfDirectoryAtPath:path error:NULL];
    NSMutableDictionary* resources = dir.resources;
    
    BOOL needsUpdate = NO; // Assets needs to be reloaded in editor
    BOOL resourcesChanged = NO;  // A resource file was modified, added or removed
    
    [self clearTouchedForResInDir:dir];
    
    for (NSString* fileShort in files)
    {
        NSString* file = [path stringByAppendingPathComponent:fileShort];
        
        RMResource* res = [resources objectForKey:file];
        NSDictionary* attr = [fm attributesOfItemAtPath:file error:NULL];
        NSDate* modifiedTime = [attr fileModificationDate];
        
        if (res)
        {
            if ([res.modifiedTime compare:modifiedTime] == NSOrderedSame)
            {
                // Skip files that are not modified
                res.touched = YES;
                continue;
            }
            else
            {
                // A resource has been modified, we need to reload assets
                res.modifiedTime = modifiedTime;
                res.type = [self getResourceTypeForFile:file];
                
                // Reload its data
                [res loadData];
                
                needsUpdate = YES;
                resourcesChanged = YES;
            }
        }
        else
        {
            // This is a new resource, add it!
            res = [[RMResource alloc] init];
            res.modifiedTime = modifiedTime;
            res.type = [self getResourceTypeForFile:file];
            res.filePath = file;
            
            // Load basic resource data if neccessary
            [res loadData];
            
            // Check if it is a directory
            if (res.type == kCCBResTypeDirectory)
            {
                [self addDirectory:file];
                res.data = [directories objectForKey:file];
            }
            
            [resources setObject:res forKey:file];
            
            if (res.type != kCCBResTypeNone) resourcesChanged = YES;
        }
        res.touched = YES;
    }
    
    // Check for deleted files
    NSMutableArray* removedFiles = [NSMutableArray array];
    
    for (NSString* file in resources)
    {
        RMResource* res = [resources objectForKey:file];
        if (!res.touched)
        {
            [removedFiles addObject:file];
            needsUpdate = YES;
            if (res.type != kCCBResTypeNone) resourcesChanged = YES;
        }
    }
    
    // Remove references to files marked for deletion
    for (NSString* file in removedFiles)
    {
        [resources removeObjectForKey:file];
    }
    
    // Update arrays for different resources
    if (resChanged)
    {
        [dir.images removeAllObjects];
        [dir.animations removeAllObjects];
        [dir.bmFonts removeAllObjects];
        [dir.ttfFonts removeAllObjects];
        [dir.ccbFiles removeAllObjects];
        
        for (NSString* file in resources)
        {
            RMResource* res = [resources objectForKey:file];
            if (res.type == kCCBResTypeImage
                || res.type == kCCBResTypeSpriteSheet
                || res.type == kCCBResTypeDirectory)
            {
                [dir.images addObject:res];
            }
            if (res.type == kCCBResTypeAnimation
                || res.type == kCCBResTypeDirectory)
            {
                [dir.animations addObject:res];
            }
            if (res.type == kCCBResTypeBMFont
                || res.type == kCCBResTypeDirectory)
            {
                [dir.bmFonts addObject:res];
            }
            if (res.type == kCCBResTypeTTF
                || res.type == kCCBResTypeDirectory)
            {
                [dir.ttfFonts addObject:res];
            }
            if (res.type == kCCBResTypeCCBFile)
            {
                [dir.ccbFiles addObject:res];
            }
        }
        
        [dir.images sortUsingSelector:@selector(compare:)];
        [dir.animations sortUsingSelector:@selector(compare:)];
        [dir.bmFonts sortUsingSelector:@selector(compare:)];
        [dir.ttfFonts sortUsingSelector:@selector(compare:)];
        [dir.ccbFiles sortUsingSelector:@selector(compare:)];
    }
    
    if (resourcesChanged) [self notifyResourceObserversResourceListUpdated];
    if (needsUpdate)
    {
        [[[CCBGlobals globals] appDelegate] reloadResources];
    }
}

- (void) addDirectory:(NSString *)dirPath
{
    // Check if directory is already added (then add to its count)
    RMDirectory* dir = [directories objectForKey:dirPath];
    if (dir)
    {
        dir.count++;
    }
    else
    {
        dir = [[[RMDirectory alloc] init] autorelease];
        dir.count = 1;
        dir.dirPath = dirPath;
        [directories setObject:dir forKey:dirPath];
        
        [self updatedWatchedPaths];
    }
    
    [self updateResourcesForPath:dirPath];
}

- (void) removeDirectory:(NSString *)dirPath
{
    RMDirectory* dir = [directories objectForKey:dirPath];
    if (dir)
    {
        // Remove sub directories
        NSDictionary* resources = dir.resources;
        for (NSString* file in resources)
        {
            RMResource* res = [resources objectForKey:file];
            if (res.type == kCCBResTypeDirectory)
            {
                [self removeDirectory:file];
            }
        }
        
        dir.count--;
        if (!dir.count)
        {
            [directories removeObjectForKey:dirPath];
            [self updatedWatchedPaths];
        }
    }
}

- (void) setActiveDirectories:(NSArray *)ad
{
    [activeDirectories removeAllObjects];
    
    for (NSString* dirPath in ad)
    {
        RMDirectory* dir = [directories objectForKey:dirPath];
        if (dir)
        {
            [activeDirectories addObject:dir];
        }
    }
    
    [self notifyResourceObserversResourceListUpdated];
}

- (void) setActiveDirectory:(NSString *)dir
{
    [self setActiveDirectories:[NSArray arrayWithObject:dir]];
}

- (void) addResourceObserver:(id)observer
{
    [resourceObserver addObject:observer];
}

- (void) removeResourceObserver:(id)observer
{
    [resourceObserver removeObject:observer];
}

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
    [[[CCDirector sharedDirector] view] lockOpenGLContext];
    [self updateResourcesForPath:event.eventPath];
    [[[CCDirector sharedDirector] view] unlockOpenGLContext];
}


- (NSString*) mainActiveDirectoryPath
{
    if ([activeDirectories count] == 0) return NULL;
    RMDirectory* dir = [activeDirectories objectAtIndex:0];
    return dir.dirPath;
}

- (NSString*) toAbsolutePath:(NSString*)path
{
    if ([activeDirectories count] == 0) return NULL;
    NSFileManager* fm = [NSFileManager defaultManager];
    
    for (RMDirectory* dir in activeDirectories)
    {
        NSString* p = [NSString stringWithFormat:@"%@/%@",dir.dirPath,path];
        if ([fm fileExistsAtPath:p]) return p;
    }
    return NULL;
}

- (void) debugPrintDirectories
{
    NSLog(@"directories: %@", directories);
    NSLog(@"activeDirectories: %@", activeDirectories);
}

@end
