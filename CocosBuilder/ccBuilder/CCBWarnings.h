//
//  CCBWarnings.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBWarning : NSObject
{
    NSString* description;
    BOOL fatal;
}
@property (nonatomic,copy) NSString* description;
@property (nonatomic,assign) BOOL fatal;

@end

@interface CCBWarnings : NSObject
{
    NSMutableArray* warnings;
}
@property (nonatomic,readonly) NSMutableArray* warnings;

- (void) addWarningWithDescription:(NSString*)description isFatal:(BOOL)fatal;
- (void) addWarningWithDescription:(NSString*)description;
- (void) addWarning:(CCBWarning*)warning;

@end
