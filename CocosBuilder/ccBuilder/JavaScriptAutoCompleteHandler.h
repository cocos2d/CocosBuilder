//
//  JavaScriptAutoCompleteHandler.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/12/13.
//
//

#import <Foundation/Foundation.h>
#import "SMLAutoCompleteDelegate.h"

@interface JavaScriptAutoCompleteHandler : NSObject <SMLAutoCompleteDelegate>
{
    NSMutableSet* globalVariableNames;
    NSMutableDictionary* localFiles;
    NSMutableDictionary* localFunctionNames;
}

+ (id) sharedAutoCompleteHandler;

- (void) loadGlobalFile:(NSString*) file;
- (void) loadGlobalFilesFromDirectory:(NSString*) dir;

- (void) loadLocalFile:(NSString*) file script:(NSString*)script addWithErrors:(BOOL) addWithErrors;
- (void) loadLocalFile:(NSString*) file;

- (void) removeLocalFiles;

- (NSArray*) functionLocationsForFile:(NSString*)file;

@end
