//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBDocument : NSObject {
    NSString* fileName;
    NSMutableDictionary* docData;
    NSUndoManager* undoManager;
    NSString* lastEditedProperty;
    BOOL isDirty;
    CGPoint stageScrollOffset;
    float stageZoom;
}

@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,retain) NSMutableDictionary* docData;
@property (nonatomic,retain) NSUndoManager* undoManager;
@property (nonatomic,retain) NSString* lastEditedProperty;
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) CGPoint stageScrollOffset;
@property (nonatomic,assign) float stageZoom;
- (NSString*) formattedName;

@end
