//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBDocument.h"


@implementation CCBDocument

@synthesize fileName,docData,undoManager, lastEditedProperty, isDirty, stageScrollOffset, stageZoom, exportPath, exportPlugIn, project;

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
    [fileName release];
    fileName = [fn retain];
    
    // Check for project file
    NSString* projPath = [[fileName stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Project.ccbproj"];
    project = [NSDictionary dictionaryWithContentsOfFile:projPath];
    [project retain];
}

@end
