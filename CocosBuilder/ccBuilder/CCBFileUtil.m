//
//  CCBFileUtil.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBFileUtil.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBDocument.h"
#import "ResolutionSetting.h"

@implementation CCBFileUtil

+ (NSString*) toResolutionIndependentFile:(NSString*)file
{
    CocosBuilderAppDelegate* ad = [[CCBGlobals globals] appDelegate];
    
    if (!ad.currentDocument)
    {
        NSLog(@"No document!");
        return file;
    }
    
    NSArray* resolutions = ad.currentDocument.resolutions;
    if (!resolutions)
    {
        NSLog(@"No resolutions!");
        return file;
    }
    
    NSString* fileType = [file pathExtension];
    NSString* fileNoExt = [file stringByDeletingPathExtension];
    
    ResolutionSetting* res = [resolutions objectAtIndex:ad.currentDocument.currentResolution];
    
    for (NSString* ext in res.exts)
    {
        if ([ext isEqualToString:@""]) continue;
        
        NSString* resFile = [NSString stringWithFormat:@"%@-%@.%@",fileNoExt,ext,fileType];
        
        NSLog(@"Testing resFile: %@", resFile);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:resFile])
        {
            return resFile;
        }
    }
    return file;
}

@end
