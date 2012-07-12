//
//  JavaScriptDocument.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGSFragaria;
@class SMLTextView;

@interface JavaScriptDocument : NSDocument
{
    IBOutlet NSView* jsView;
    IBOutlet NSWindow* docWindow;
    
    MGSFragaria* fragaria;
    SMLTextView* fragariaTextView;
    
    NSString* docStr;
}
@end
