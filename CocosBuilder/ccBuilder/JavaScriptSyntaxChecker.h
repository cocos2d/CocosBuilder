//
//  JavaScriptSyntaxChecker.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@class JavaScriptDocument;

@interface JavaScriptSyntaxChecker : NSObject
{
    NSTask* syntaxTask;
}

@property (nonatomic,assign) JavaScriptDocument* document;

- (void) checkText:(NSString*)text;

@end
