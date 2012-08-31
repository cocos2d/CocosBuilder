//
//  HelpPage.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpPage : NSObject
{
    NSString* fileName;
    NSString* contents;
}

@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,readonly) NSString* pageName;
@property (nonatomic,retain) NSString* contents;

@end
