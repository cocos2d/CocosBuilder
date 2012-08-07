/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
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

@interface CCBDocument : NSObject {
    NSString* fileName;
    NSString* exportPath;
    NSString* exportPlugIn;
    BOOL exportFlattenPaths;
    NSMutableDictionary* docData;
    NSUndoManager* undoManager;
    NSString* lastEditedProperty;
    BOOL isDirty;
    CGPoint stageScrollOffset;
    float stageZoom;
    
    NSMutableArray* resolutions;
    int currentResolution;
    
    NSMutableArray* sequences;
    int currentSequenceId;
}

@property (nonatomic,retain) NSString* fileName;
@property (nonatomic,retain) NSString* exportPath;
@property (nonatomic,retain) NSString* exportPlugIn;
@property (nonatomic,assign) BOOL exportFlattenPaths;
@property (nonatomic,retain) NSMutableDictionary* docData;
@property (nonatomic,retain) NSUndoManager* undoManager;
@property (nonatomic,retain) NSString* lastEditedProperty;
@property (nonatomic,assign) BOOL isDirty;
@property (nonatomic,assign) CGPoint stageScrollOffset;
@property (nonatomic,assign) float stageZoom;
@property (nonatomic,readonly) NSString* rootPath;
- (NSString*) formattedName;
@property (nonatomic,retain) NSMutableArray* resolutions;
@property (nonatomic,assign) int currentResolution;
@property (nonatomic,retain) NSMutableArray* sequences;
@property (nonatomic,assign) int currentSequenceId;
@end
