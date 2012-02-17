//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NewDocWindowController : NSWindowController
{
    NSArray* rootObjectTypes;
    NSString* rootObjectType;

    int wStage;
    int hStage;
    
    int centeredStageOrigin;
}

@property (nonatomic,retain) NSArray* rootObjectTypes;
@property (nonatomic,retain) NSString* rootObjectType;
@property (nonatomic,assign) int wStage;
@property (nonatomic,assign) int hStage;
@property (nonatomic,assign) int centeredStageOrigin;

- (IBAction)acceptSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;

@end
