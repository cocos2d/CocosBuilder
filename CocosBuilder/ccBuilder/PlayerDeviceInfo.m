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

- (void) dealloc
{
    [identifier release];
    [deviceName release];
    [deviceType release];
    [preferredResourceType release];
    
    [super dealloc];
}

@end
