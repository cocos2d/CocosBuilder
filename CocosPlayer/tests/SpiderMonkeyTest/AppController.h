
#import "BaseAppController.h"
#import "cocos2d.h"

@class ServerController;
@class PlayerStatusLayer;

@interface AppController : BaseAppController
{
    ServerController* server;
    NSString* serverStatus;
    PlayerStatusLayer* statusLayer;
}

+ (AppController*) appController;

- (void) setStatus:(NSString*)status forceStop:(BOOL)forceStop;

- (void) runJSApp;
- (void) stopJSApp;

- (void) updatePairing;

@end

