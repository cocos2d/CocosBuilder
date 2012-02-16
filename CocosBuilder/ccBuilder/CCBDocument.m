//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBDocument.h"


@implementation CCBDocument

@synthesize fileName,docData,undoManager, lastEditedProperty, isDirty, stageScrollOffset, stageZoom;

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
    self.lastEditedProperty = NULL;
    self.fileName = NULL;
    self.docData = NULL;
    self.undoManager = NULL;
    [super dealloc];
}

- (NSString*) formattedName
{
    return [[self.fileName lastPathComponent] stringByDeletingPathExtension];
}

@end
