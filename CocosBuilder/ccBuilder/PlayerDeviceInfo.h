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
    NSString* preferredResourceType;
    NSString* uuid;
    BOOL hasRetinaDisplay;
    BOOL populated;
    NSDictionary* fileList;
}

@property (nonatomic,copy) NSString* identifier;
@property (nonatomic,copy) NSString* deviceName;
@property (nonatomic,copy) NSString* deviceType;
@property (nonatomic,copy) NSString* preferredResourceType;
@property (nonatomic,copy) NSString* uuid;
@property (nonatomic,assign) BOOL hasRetinaDisplay;
@property (nonatomic,assign) BOOL populated;
@property (nonatomic,retain) NSDictionary* fileList;

@end
