//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum {
    kCCBMemberVarAssignmentTypeNone = 0,
    kCCBMemberVarAssignmentTypeDocumentRoot = 1,
    kCCBMemberVarAssignmentTypeOwner = 2,
};

// CCBReader
@interface CCBReaderInternalV1 : NSObject {
@private
    
}
+ (CCScene*) sceneWithNodeGraphFromFile:(NSString*) file;
+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner;

+ (CCNode*) nodeGraphFromFile:(NSString*) file;
+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner;

+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict;
+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict owner:(NSObject*) owner;


+ (CCNode*) nodeGraphFromDictionary:(NSDictionary*) dict assetsDir:(NSString*)path owner:(NSObject*)owner;
+ (CCNode*) ccObjectFromDictionary: (NSDictionary *)dict assetsDir:(NSString*)path owner:(NSObject*)owner;
@end

// CCBTemplate
@interface CCBTemplate : NSObject
{
    NSString* fileName;
    NSString* assetsPath;
    NSString* propertyFile;
    NSString* customClass;
    NSString* previewImage;
    CGPoint previewAnchorpoint;
    id properties;
}

@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, retain) NSString* assetsPath;
@property (nonatomic, retain) NSString* propertyFile;
@property (nonatomic, retain) NSString* customClass;
@property (nonatomic, retain) NSString* previewImage;
@property (nonatomic, assign) CGPoint previewAnchorpoint;
@property (nonatomic, retain) id properties;

- (id) initWithFile:(NSString*) f assetsPath:(NSString*)ap;
- (id) initWithNonExistingPath:(NSString*)f;
- (void) store;

@end

// CCBTemplateNode
@class CCBTemplate;

@interface CCBTemplateNode : CCSprite
{
    CCBTemplate* ccbTemplate;
    
}

@property (nonatomic,retain) CCBTemplate* ccbTemplate;

- (id)initWithTemplate:(CCBTemplate*)t;

@end
