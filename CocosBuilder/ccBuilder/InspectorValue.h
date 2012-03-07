//
//  Inspector.h
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CocosBuilderAppDelegate;

@interface InspectorValue : NSObject
{
    CCNode* selection;
    NSString* propertyName;
    NSString* displayName;
    NSString* extra;
    
    CocosBuilderAppDelegate* resourceManager;
    
    IBOutlet NSView* view;
    BOOL readOnly;
    NSArray* affectsProperties;
}

@property (nonatomic,readonly) NSString* displayName;
@property (nonatomic,readonly) NSView* view;
@property (nonatomic,readonly) NSString* extra;
@property (nonatomic,assign) BOOL readOnly;
@property (nonatomic,retain) NSArray* affectsProperties;

+ (id) inspectorOfType:(NSString*) t withSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e;

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e;

- (void) refresh;

- (void) willBeAdded;
- (void) willBeRemoved;

- (void) updateAffectedProperties;

- (id) propertyForSelection;
- (void) setPropertyForSelection:(id)value;

- (id) propertyForSelectionX;
- (void) setPropertyForSelectionX:(id)value;

- (id) propertyForSelectionY;
- (void) setPropertyForSelectionY:(id)value;

- (id) propertyForSelectionVar;
- (void) setPropertyForSelectionVar:(id)value;

@end
