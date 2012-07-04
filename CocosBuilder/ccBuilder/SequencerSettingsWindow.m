//
//  SequencerSettingsWindow.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SequencerSettingsWindow.h"
#import "SequencerSequence.h"

@implementation SequencerSettingsWindow

@synthesize sequences;

- (void) copySequences:(NSMutableArray *)seqs
{
    self.sequences = [[NSMutableArray arrayWithCapacity:[seqs count]] retain];
    
    for (SequencerSequence* seq in seqs)
    {
        SequencerSequence* seqCopy = [[seq copy] autorelease];
        seqCopy.settingsWindow = self;
        [sequences addObject:seqCopy];
    }
}

- (BOOL) sheetIsValid
{
    if ([self.sequences count] > 0)
    {
        return YES;
    }
    else
    {
        // Display warning!
        NSAlert* alert = [NSAlert alertWithMessageText:@"Missing Timeline" defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"You need to have at least one timeline in your document."];
        [alert beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
        
        return NO;
    }
}

- (void) disableAutoPlayForAllItems
{
    NSLog(@"disableAutoPlay %@", self.sequences);
    
    for (SequencerSequence* seq in self.sequences)
    {
        NSLog(@" -");
        seq.autoPlay = NO;
    }
}

- (void) dealloc
{
    self.sequences = NULL;
    [super dealloc];
}

@end
