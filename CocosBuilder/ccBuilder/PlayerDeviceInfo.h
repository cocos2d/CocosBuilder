//
//  PlayerDeviceInfo.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 11/1/12.
//
//

#import <Foundation/Foundation.h>

@interface PlayerDeviceInfo : NSObject
{
    NSString* identifier;
    NSString* deviceName;
    NSString* deviceType;
    BOOL hasRetinaDisplay;
    BOOL populated;
}

@property (nonatomic,copy) NSString* identifier;
@property (nonatomic,copy) NSString* deviceName;
@property (nonatomic,copy) NSString* deviceType;
@property (nonatomic,assign) BOOL hasRetinaDisplay;
@property (nonatomic,assign) BOOL populated;

@end
