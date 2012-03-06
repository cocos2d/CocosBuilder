//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCBDocument : NSObject {
    NSString* fileName;
    NSString* exportPath;
    NSString* exportPlugIn;
    NSMutableDictionary* docData;
    NSUndoManager* undoManager;
    NSString* lastEditedProperty;
    BOOL isDirty;
    CGPoint stageScrollOffset;
    float stageZoom;
}

@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,retain) NSString* exportPath;
@property (nonatomic,retain) NSString* exportPlugIn;
@property (nonatomic,retain) NSMutableDictionary* docData;
@property (nonatomic,retain) NSUndoManager* undoManager;
@property (nonatomic,retain) NSString* lastEditedProperty;
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) CGPoint stageScrollOffset;
@property (nonatomic,assign) float stageZoom;
@property (nonatomic,readonly) NSString* rootPath;
- (NSString*) formattedName;

@end
