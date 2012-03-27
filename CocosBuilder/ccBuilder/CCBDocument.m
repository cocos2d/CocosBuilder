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

#import "CCBDocument.h"


@implementation CCBDocument

@synthesize fileName,docData,undoManager, lastEditedProperty, isDirty, stageScrollOffset, stageZoom, exportPath, exportPlugIn,exportFlattenPaths, project;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.undoManager = [[[NSUndoManager alloc] init] autorelease];
    }
    
    self.stageZoom = 1;
    self.stageScrollOffset = ccp(0,0);
    
    return self;
}

- (void)dealloc
{
    [project release];
    self.exportPath = NULL;
    self.exportPlugIn = NULL;
    self.lastEditedProperty = NULL;
    [fileName release];
    self.docData = NULL;
    self.undoManager = NULL;
    [super dealloc];
}

- (NSString*) formattedName
{
    return [[self.fileName lastPathComponent] stringByDeletingPathExtension];
}

- (NSString*) rootPath
{
    return [fileName stringByDeletingLastPathComponent];
}

- (void) setFileName:(NSString *)fn
{
    // Set new filename
    if (fn != fileName)
    {
        [fileName release];
        fileName = [fn retain];
    }
    // Check for project file
    NSString* projPath = [[fileName stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Project.ccbproj"];
    project = [NSDictionary dictionaryWithContentsOfFile:projPath];
    [project retain];
}

@end
