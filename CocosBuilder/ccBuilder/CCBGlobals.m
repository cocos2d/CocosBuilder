//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"


@implementation CCBGlobals

@synthesize rootNode, cocosScene, numRuns, hasDonated,appDelegate;

+ (CCBGlobals*) globals
{
    static CCBGlobals* g = NULL;
    if (g == NULL)
    {
        g = [[CCBGlobals alloc] init];
    }
    return g;
}

- (id)init
{
    self = [super init];
    if (!self) return NULL;
    
    numRuns = [[[NSUserDefaults standardUserDefaults] valueForKey:@"numRuns"] intValue];
    hasDonated = [[[NSUserDefaults standardUserDefaults] valueForKey:@"hasDonated"] boolValue];
    
    numRuns++;
    [self writeSettings];
    
    return self;
}

- (void) writeSettings
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:numRuns] forKey:@"numRuns"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:hasDonated] forKey:@"hasDonated"];
}

- (void)dealloc
{
    rootNode = NULL;
    cocosScene = NULL;
    [super dealloc];
}



@end
