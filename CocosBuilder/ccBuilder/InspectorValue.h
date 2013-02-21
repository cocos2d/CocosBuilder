/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CocosBuilderAppDelegate;

@interface InspectorValue : NSObject <NSControlTextEditingDelegate>
{
    CCNode* selection;
    NSString* propertyName;
    NSString* displayName;
    NSString* extra;
    
    CocosBuilderAppDelegate* resourceManager;
    
    IBOutlet NSView* view;
    BOOL readOnly;
    NSArray* affectsProperties;
    InspectorValue* inspectorValueBelow;
    BOOL rootNode;
    BOOL inPopoverWindow;
    
    NSString* textFieldOriginalValue;
}

@property (nonatomic,readonly) NSString* displayName;
@property (nonatomic,readonly) NSView* view;
@property (nonatomic,readonly) NSString* extra;
@property (nonatomic,assign) BOOL readOnly;
@property (nonatomic,assign) BOOL rootNode;
@property (nonatomic,retain) NSArray* affectsProperties;
@property (nonatomic,retain) InspectorValue* inspectorValueBelow;
@property (nonatomic,assign) BOOL inPopoverWindow;
@property (nonatomic,retain) NSString* textFieldOriginalValue;

+ (id) inspectorOfType:(NSString*) t withSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e;

- (id) initWithSelection:(CCNode*)s andPropertyName:(NSString*)pn andDisplayName:(NSString*) dn andExtra:(NSString*)e;

- (void) refresh;

- (void) willBeAdded;
- (void) willBeRemoved;

- (void) updateAffectedProperties;

- (id) propertyForSelection;
- (void) updateAnimateablePropertyValue:(id)value;
- (void) setPropertyForSelection:(id)value;

- (id) propertyForSelectionX;
- (void) setPropertyForSelectionX:(id)value;

- (id) propertyForSelectionY;
- (void) setPropertyForSelectionY:(id)value;

- (id) propertyForSelectionVar;
- (void) setPropertyForSelectionVar:(id)value;

- (void)hideAllToNextSeparatorWithAboveSeparator:(InspectorValue*)aboveSeparator;
- (void)showAllToNextSeparatorWithAbove:(InspectorValue*)above;
- (void)moveToMeetAbove:(InspectorValue*)above;
- (BOOL)isSeparator;
- (BOOL)setSuperviewFrameHeight;

@end
