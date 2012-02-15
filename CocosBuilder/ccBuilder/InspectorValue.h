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
    
    CocosBuilderAppDelegate* resourceManager;
    
    IBOutlet NSView* view;
    BOOL readOnly;
    NSArray* affectsProperties;
}

@property (nonatomic,readonly) NSString* displayName;
@property (nonatomic,readonly) NSView* view;
//@property (nonatomic,assign) CocosBuilderAppDelegate* resourceManager;
@property (nonatomic,assign) BOOL readOnly;
@property (nonatomic,retain) NSArray* affectsProperties;

+ (id) inspectorOfType:(NSString*) t withSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn;

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn;

- (void) refresh;
- (void) updateAffectedProperties;

- (id) propertyForSelection;
- (void) setPropertyForSelection:(id)value;

- (id) propertyForSelectionX;
- (void) setPropertyForSelectionX:(id)value;

- (id) propertyForSelectionY;
- (void) setPropertyForSelectionY:(id)value;

@end
