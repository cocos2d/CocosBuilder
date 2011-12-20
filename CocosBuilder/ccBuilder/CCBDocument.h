//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum {
    kCCBOperationTypeUnspecified = 0,
    kCCBOperationTypePosition = 1,
    kCCBOperationTypeRotate = 2,
    kCCBOperationTypeScale = 3,
    kCCBOperationTypeColor = 4,
    kCCBOperationTypeFadeColor = 5
};

@interface CCBDocument : NSObject {
    NSString* fileName;
    NSMutableDictionary* docData;
    NSUndoManager* undoManager;
    int lastOperationType;
    BOOL isDirty;
    CGPoint stageScrollOffset;
    float stageZoom;
}

@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,retain) NSMutableDictionary* docData;
@property (nonatomic,retain) NSUndoManager* undoManager;
@property (nonatomic,assign) int lastOperationType;
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) CGPoint stageScrollOffset;
@property (nonatomic,assign) float stageZoom;
- (NSString*) formattedName;

@end
