//
//  ConsoleWindow.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConsoleWindow : NSWindowController
{
    int originalStdErr;
    NSString* logPath;
    NSFileHandle* fileHandle;
    unsigned long long fileOffset;
}


@end
