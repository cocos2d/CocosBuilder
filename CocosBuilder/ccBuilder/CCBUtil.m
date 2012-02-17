//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBUtil.h"


@implementation CCBUtil


+ (void) setSelectedSubmenuItemForMenu:(NSMenu*)menu tag:(int)tag
{
    NSArray* items = [menu itemArray];
    for (int i = 0; i < [items count]; i++)
    {
        [[items objectAtIndex:i] setState:NSOffState];
    }
    [[menu itemWithTag:tag] setState:NSOnState];
}

+ (NSArray*) findFilesOfType:(NSString*)type inDirectory:(NSString*)d
{
    NSMutableArray* result = [NSMutableArray array];
    
    NSArray* dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:d error:NULL];
    for (int i = 0; i < [dir count]; i++)
    {
        NSString* f = [dir objectAtIndex:i];
        
        if ([[f stringByDeletingPathExtension] hasSuffix:@"-hd"])
        {
            continue;
        }
        
        if ([[[f pathExtension] lowercaseString] isEqualToString:type])
        {
            [result addObject:f];
        }
    }
    
    return result;
}



@end
