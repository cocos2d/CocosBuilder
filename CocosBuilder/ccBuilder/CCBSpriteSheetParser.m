//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBSpriteSheetParser.h"

static NSInteger strSort(id num1, id num2, void *context)
{
    return [(NSString*)num1 compare:num2 options:NSNumericSearch];
}

@implementation CCBSpriteSheetParser

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (BOOL) isSpriteSheetFile:(NSString*) file
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:file];
    
    NSNumber* docVersion = [[dict objectForKey:@"metadata"] objectForKey:@"format"];
    if (!docVersion) return NO;
    
    if ([docVersion intValue] >= 0 && [docVersion intValue] <= 3)
    {
        if ([dict objectForKey:@"frames"]) return YES;
    }
    return NO;
}

+ (NSMutableArray*) findSpriteSheetsAtPath:(NSString*)assetsPath
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSArray* dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:assetsPath error:NULL];
    for (int i = 0; i < [dir count]; i++)
    {
        NSString* file = [dir objectAtIndex:i];
        
        NSString* pathExt = [file pathExtension];
        NSString* absFile = [NSString stringWithFormat:@"%@%@",assetsPath, file];
        BOOL isHDFile = [[file stringByDeletingPathExtension] hasSuffix:@"-hd"];
        
        if ([pathExt isEqualToString:@"plist"] && [CCBSpriteSheetParser isSpriteSheetFile:absFile])
        {
            if (!isHDFile)
            {
                [array addObject:file];
                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:absFile];
            }
        }
    }
    return array;
}

+ (NSMutableArray*) listFramesInSheet:(NSString *)absoluteFile
{
    NSMutableArray* frames = [NSMutableArray array];
    
    if ([CCBSpriteSheetParser isSpriteSheetFile:absoluteFile])
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:absoluteFile];
        
        NSDictionary* dictFrames = [dict objectForKey:@"frames"];
        for (NSString* frameKey in dictFrames)
        {
            [frames addObject:frameKey];
        }
    }
    
    [frames sortUsingFunction:strSort context:NULL];
    
    return frames;
}

+ (NSMutableArray*) listFramesInSheet:(NSString*)file assetsPath:(NSString*) assetsPath
{
    NSString* absoluteFile = [NSString stringWithFormat:@"%@%@",assetsPath,file];
    
    return [CCBSpriteSheetParser listFramesInSheet:absoluteFile];
}

@end
