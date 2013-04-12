//
//  JavaScriptVariableExtractor.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@interface JavaScriptVariableExtractor : NSObject
{
    NSMutableSet* variableNames;
    
    BOOL openString;
}

@property (nonatomic,readonly) NSSet* variableNames;
@property (nonatomic,readonly) BOOL hasErrors;

- (void) parseScript:(NSString*) script;

@end
