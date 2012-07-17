
#import "BaseAppController.h"
#import "cocos2d.h"

@class ServerController;

@interface AppController : BaseAppController
{
    ServerController* server;
    CCScene* statusScene;
}

+ (AppController*) appController;

- (void) setStatus:(NSString*)status forceStop:(BOOL)forceStop;

- (void) runJSApp;
- (void) stopJSApp;

- (void) updatePairing;

@end

