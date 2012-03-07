//
//  ResourceManagerUtil.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourceManagerUtil.h"
#import "ResourceManager.h"

@implementation ResourceManagerUtil

+ (void) addDirectory: (RMDirectory*) dir ToMenu: (NSMenu*) menu target:(id)target allowSpriteFrames:(BOOL) allowSpriteFrames
{
    NSArray* arr = [dir resourcesForType:kCCBResTypeImage];
    
    for (id item in arr)
    {
        if ([item isKindOfClass:[RMResource class]])
        {
            RMResource* res = item;
            
            if (res.type == kCCBResTypeImage)
            {
                NSString* itemName = [res.filePath lastPathComponent];
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:@selector(selectedTexture:) keyEquivalent:@""] autorelease];
                [menuItem setTarget:target];
                [menu addItem:menuItem];
                
                menuItem.representedObject = res;
            }
            else if (res.type == kCCBResTypeSpriteSheet && allowSpriteFrames)
            {
                NSString* itemName = [res.filePath lastPathComponent];
                
                NSMenu* subMenu = [[[NSMenu alloc] initWithTitle:itemName] autorelease];
                
                NSArray* frames = res.data;
                for (RMSpriteFrame* frame in frames)
                {
                    NSMenuItem* subItem = [[[NSMenuItem alloc] initWithTitle:frame.spriteFrameName action:@selector(selectedTexture:) keyEquivalent:@""] autorelease];
                    [subItem setTarget:target];
                    [subMenu addItem:subItem];
                    subItem.representedObject = frame;
                }
                
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""] autorelease];
                [menu addItem:menuItem];
                [menu setSubmenu:subMenu forItem:menuItem];
            }
            else if (res.type == kCCBResTypeDirectory)
            {
                RMDirectory* subDir = res.data;
                
                NSString* itemName = [subDir.dirPath lastPathComponent];
                
                NSMenu* subMenu = [[[NSMenu alloc] initWithTitle:itemName] autorelease];
                
                [ResourceManagerUtil addDirectory:subDir ToMenu:subMenu target:target allowSpriteFrames:allowSpriteFrames];
                
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""] autorelease];
                [menu addItem:menuItem];
                [menu setSubmenu:subMenu forItem:menuItem];
            }
        }
    }
}

+ (void) populateTexturePopup:(NSPopUpButton*)popup allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString*)file selectedSheet:(NSString*) sheetFile target:(id)target
{
    // TODO: Add support for multiple directories
    
    // Clear the menu and add items to it!
    NSMenu* menu = [popup menu];
    [menu removeAllItems];
    
    ResourceManager* rm = [ResourceManager sharedManager];
    
    if ([rm.activeDirectories count] == 0) return;
    RMDirectory* activeDir = [rm.activeDirectories objectAtIndex:0];
    
    [ResourceManagerUtil addDirectory:activeDir ToMenu:menu target:target allowSpriteFrames:allowSpriteFrames];
    
    // Set the selected item
    NSString* selectedTitle = NULL;
    if (sheetFile)
    {
        selectedTitle = [NSString stringWithFormat:@"%@/%@",sheetFile,file];
    }
    else
    {
        selectedTitle = file;
    }
    [popup setTitle:selectedTitle];
}

+ (NSString*) relativePathFromAbsolutePath: (NSString*) path
{
    // TODO: Add support for multiple directories
    
    NSArray* activeDirs = [[ResourceManager sharedManager] activeDirectories];
    if ([activeDirs count] == 0) return NULL;
    
    RMDirectory* baseDir = [activeDirs objectAtIndex:0];
    NSString* base = baseDir.dirPath;
    
    int baseLen = [base length];
    
    NSString* relPath = [path substringFromIndex:baseLen+1];
    
    if (![[base substringToIndex:baseLen] isEqualToString:base])
    {
        NSLog(@"No relative path!!");
        return NULL;
    }
    
    return relPath;
}

+ (void) setTitle:(NSString*)str forPopup:(NSPopUpButton*)popup
{
    NSMenu* menu = [popup menu];
    
    // Remove items that contains a slash (/)
    NSArray* items = [[[menu itemArray] copy] autorelease];
    for (NSMenuItem* item in items)
    {
        NSRange range = [item.title rangeOfString:@"/"];
        if (range.location == NSNotFound) continue;
        [menu removeItem:item];
    }
    
    // Set the title
    [popup setTitle:str];
}

@end
