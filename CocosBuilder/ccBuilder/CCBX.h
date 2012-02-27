//
//  CCBX.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBX : NSObject

- (NSString*) extension;
- (NSData*) exportDocument:(NSDictionary*)doc;

@end
