//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCBUtil : NSObject {  
}
+ (void) endEditingForView:(NSView*)view;
+ (void) setSelectedSubmenuItemForMenu:(NSMenu*)menu tag:(int)tag;
+ (NSArray*) findFilesOfType:(NSString*)type inDirectory:(NSString*)d;
@end
