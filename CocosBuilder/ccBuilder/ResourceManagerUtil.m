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

#import "ResourceManagerUtil.h"
#import "ResourceManager.h"

@implementation ResourceManagerUtil

+ (void) setTitle:(NSString*)str forPopup:(NSPopUpButton*)popup forceMarker:(BOOL) forceMarker
{
    NSMenu* menu = [popup menu];
    if (!str) str = @"";
    
    // Remove items that contains a slash (/ or •)
    NSArray* items = [[[menu itemArray] copy] autorelease];
    for (NSMenuItem* item in items)
    {
        NSRange range0 = [item.title rangeOfString:@"/"];
        NSRange range1 = [item.title rangeOfString:@"•"];
        if (range0.location == NSNotFound && range1.location == NSNotFound) continue;
        
        [menu removeItem:item];
    }
    
    // Add a • in front of the name if multiple active directories are used
    if (forceMarker
        || [[[ResourceManager sharedManager] activeDirectories] count] > 1)
    {
        str = [NSString stringWithFormat:@"• %@",str];
    }
    
    // Set the title
    [popup setTitle:str];
}

+ (void) setTitle:(NSString *)str forPopup:(NSPopUpButton *)popup
{
    [self setTitle:str forPopup:popup forceMarker:NO];
}

+ (void) addDirectory: (RMDirectory*) dir ToMenu: (NSMenu*) menu target:(id)target resType:(int) resType allowSpriteFrames:(BOOL) allowSpriteFrames
{
    NSArray* arr = [dir resourcesForType:resType];
    
    for (id item in arr)
    {
        if ([item isKindOfClass:[RMResource class]])
        {
            RMResource* res = item;
            
            if (res.type == kCCBResTypeImage
                || res.type == kCCBResTypeBMFont
                || res.type == kCCBResTypeCCBFile
                || res.type == kCCBResTypeTTF
                || res.type == kCCBResTypeAudio)
            {
                NSString* itemName = [res.filePath lastPathComponent];
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:@selector(selectedResource:) keyEquivalent:@""] autorelease];
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
                    NSMenuItem* subItem = [[[NSMenuItem alloc] initWithTitle:frame.spriteFrameName action:@selector(selectedResource:) keyEquivalent:@""] autorelease];
                    [subItem setTarget:target];
                    [subMenu addItem:subItem];
                    subItem.representedObject = frame;
                }
                
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""] autorelease];
                [menu addItem:menuItem];
                [menu setSubmenu:subMenu forItem:menuItem];
            }
            else if (res.type == kCCBResTypeAnimation)
            {
                NSString* itemName = [res.filePath lastPathComponent];
                
                NSMenu* subMenu = [[[NSMenu alloc] initWithTitle:itemName] autorelease];
                
                NSArray* anims = res.data;
                for (RMAnimation* anim in anims)
                {
                    NSMenuItem* subItem = [[[NSMenuItem alloc] initWithTitle:anim.animationName action:@selector(selectedResource:) keyEquivalent:@""] autorelease];
                    [subItem setTarget:target];
                    [subMenu addItem:subItem];
                    subItem.representedObject = anim;
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
                
                [ResourceManagerUtil addDirectory:subDir ToMenu:subMenu target:target resType:resType allowSpriteFrames:allowSpriteFrames];
                
                NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""] autorelease];
                [menu addItem:menuItem];
                [menu setSubmenu:subMenu forItem:menuItem];
            }
        }
    }
}

+ (void) populateResourceMenu:(NSMenu*)menu resType:(int)resType allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString*)file selectedSheet:(NSString*) sheetFile target:(id)target
{
    // Clear the menu and add items to it!
    [menu removeAllItems];
    
    ResourceManager* rm = [ResourceManager sharedManager];
    
    if ([rm.activeDirectories count] == 0)
    {
        // No, active directory
        return;
    }
    else if ([rm.activeDirectories count] == 1)
    {
        // There is only a single active directory, make its contents the top level
        RMDirectory* activeDir = [rm.activeDirectories objectAtIndex:0];
    
        [ResourceManagerUtil addDirectory:activeDir ToMenu:menu target:target resType: resType allowSpriteFrames:allowSpriteFrames];
    }
    else
    {
        // There are more than one active directory, make a list of directories at
        // the top level
        for (RMDirectory* activeDir in rm.activeDirectories)
        {
            NSString* itemName = [activeDir.dirPath lastPathComponent];
            
            NSMenu* subMenu = [[[NSMenu alloc] initWithTitle:itemName] autorelease];
            
            [ResourceManagerUtil addDirectory:activeDir ToMenu:subMenu target:target resType:resType allowSpriteFrames:allowSpriteFrames];
            
            NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""] autorelease];
            [menu addItem:menuItem];
            [menu setSubmenu:subMenu forItem:menuItem];
        }
    }
}

+ (void) populateResourcePopup:(NSPopUpButton*)popup resType:(int)resType allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString*)file selectedSheet:(NSString*) sheetFile target:(id)target
{
    NSMenu* menu = [popup menu];
    
    [self populateResourceMenu:menu resType:resType allowSpriteFrames:allowSpriteFrames selectedFile:file selectedSheet:sheetFile target:target];
    
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
    
    [self setTitle:selectedTitle forPopup:popup];
}

+ (void) populateFontTTFPopup:(NSPopUpButton*)popup selectedFont:(NSString*)file target:(id)target
{
    NSMenu* menu = [popup menu];
    [menu removeAllItems];
    
    // System fonts submenu
    NSMenu* menuSubSystemFonts = [[[NSMenu alloc] initWithTitle:@"System Fonts"] autorelease];
    NSMenuItem* itemSystemFonts = [[[NSMenuItem alloc] initWithTitle:@"System Fonts" action:NULL keyEquivalent:@""] autorelease];
    [menu addItem:itemSystemFonts];
    [menu setSubmenu:menuSubSystemFonts forItem:itemSystemFonts];
    
    NSArray* systemFonts = [[ResourceManager sharedManager] systemFontList];
    for (NSString* fontName in systemFonts)
    {
        NSMenuItem* itemFont = [[[NSMenuItem alloc] initWithTitle:fontName action:@selector(selectedResource:) keyEquivalent:@""] autorelease];
        [itemFont setTarget:target];
        itemFont.representedObject = fontName;
        
        [menuSubSystemFonts addItem:itemFont];
    }
    
    // User fonts submenu
    NSMenu* menuSubUserFonts = [[[NSMenu alloc] initWithTitle:@"User Fonts"] autorelease];
    NSMenuItem* itemUserFonts = [[[NSMenuItem alloc] initWithTitle:@"User Fonts" action:NULL keyEquivalent:@""] autorelease];
    [menu addItem:itemUserFonts];
    [menu setSubmenu:menuSubUserFonts forItem:itemUserFonts];
    
    [self populateResourceMenu:menuSubUserFonts resType:kCCBResTypeTTF allowSpriteFrames:NO selectedFile:file selectedSheet:NULL target:target];
    
    // Set title
    [self setTitle:file forPopup:popup forceMarker:YES];
}

+ (NSString*) relativePathFromAbsolutePath: (NSString*) path
{
    NSArray* activeDirs = [[ResourceManager sharedManager] activeDirectories];
    
    for (RMDirectory* dir in activeDirs)
    {
        NSString* base = dir.dirPath;
        
        if ([path hasPrefix:base])
        {
            NSString* relPath = [path substringFromIndex:[base length]+1];
            return relPath;
        }
    }
    
    NSLog(@"WARNING! ResourceManagerUtil: No relative path");
    return NULL;
}

@end
