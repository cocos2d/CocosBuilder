//
//  JavaScriptSyntaxChecker.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 4/8/13.
//
//

#import <Foundation/Foundation.h>

@interface JavaScriptSyntaxChecker : NSObject
{
    NSString* file;
}

- (id) initWithFile:(NSString*)f;

- (NSArray*) errors;

@end
