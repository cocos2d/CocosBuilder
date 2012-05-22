//
//  CCBPFileUtils.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCBPFileUtils : CCFileUtils
{
    NSString* ccbDirectoryPath;
}

@property (nonatomic,copy) NSString* ccbDirectoryPath;

@end
