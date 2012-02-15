//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "CCBGLView.h"
#import "CocosBuilderAppDelegate.h"
#import "CCBGlobals.h"
#import "CocosScene.h"

@implementation CCBGLView

- (void) reshape
{
    [self removeTrackingRect:trackingTag];
    trackingTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    
    [super reshape];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    trackingTag = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    //[[self window] setAcceptsMouseMovedEvents:YES];
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects: @"com.cocosbuilder.texture", @"com.cocosbuilder.template", NULL]];
}


-(BOOL) acceptsFirstResponder
{
	return NO;
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSPoint pt = [self convertPoint:[sender draggingLocation] fromView:NULL];
    
    NSPasteboard* pb = [sender draggingPasteboard];
    
    NSData* pdData = [pb dataForType:@"com.cocosbuilder.texture"];
    if (pdData)
    {
        NSDictionary* pdDict = [NSKeyedUnarchiver unarchiveObjectWithData:pdData];
        [appDelegate dropAddSpriteNamed:[pdDict objectForKey:@"spriteFile"] inSpriteSheet:[pdDict objectForKey:@"spriteSheetFile"] at:ccp(pt.x,pt.y)];
    }
    /*
    pdData = [pb dataForType:@"com.cocosbuilder.template"];
    if (pdData)
    {
        NSDictionary* pdDict = [NSKeyedUnarchiver unarchiveObjectWithData:pdData];
        [appDelegate dropAddTemplateNamed:[pdDict objectForKey:@"templateFile"] at:ccp(pt.x,pt.y)];
    }
     */
    return YES;
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    [[[CCBGlobals globals] cocosScene] scrollWheel:theEvent];
}
/*
- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
}*/

@end
