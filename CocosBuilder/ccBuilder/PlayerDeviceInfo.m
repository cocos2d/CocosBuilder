//
//  PlayerDeviceInfo.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 11/1/12.
//
//

#import "PlayerDeviceInfo.h"

@implementation PlayerDeviceInfo

@synthesize identifier;
@synthesize deviceName;
@synthesize deviceType;
@synthesize hasRetinaDisplay;
@synthesize populated;
@synthesize preferredResourceType;
@synthesize uuid;
@synthesize fileList;

- (void) dealloc
{
    [identifier release];
    [deviceName release];
    [deviceType release];
    [preferredResourceType release];
    [uuid release];
    [fileList release];
    
    [super dealloc];
}

@end
