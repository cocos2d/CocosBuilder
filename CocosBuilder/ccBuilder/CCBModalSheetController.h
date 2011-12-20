//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CCBModalSheetController : NSWindowController {
@private
    
}

- (IBAction)acceptSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

- (int) runModalSheetForWindow:(NSWindow*)window;
@end
