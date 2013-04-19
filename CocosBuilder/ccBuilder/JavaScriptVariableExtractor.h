//
//  JavaScriptVariableExtractor.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/11/13.
//
//

#import <Foundation/Foundation.h>

@interface JavaScriptFunctionLocation : NSObject

@property (nonatomic,retain) NSString* functionName;
@property (nonatomic,retain) NSString* className;
@property (nonatomic,assign) int line;

@end

@interface JavaScriptVariableExtractor : NSObject
{
    NSMutableSet* variableNames;
    NSMutableArray* variableNamesAtCurrentLine;
    NSMutableArray* functionLocations;
    
    int lineNumber;
    BOOL openString;
}

@property (nonatomic,readonly) NSSet* variableNames;
@property (nonatomic,readonly) NSArray* functionLocations;
@property (nonatomic,readonly) BOOL hasErrors;

- (void) parseScript:(NSString*) script;

@end
