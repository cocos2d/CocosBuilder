//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NewDocWindowController : NSWindowController
{
    IBOutlet NSPopUpButton* rootObjectPop;
    IBOutlet NSPopUpButton* templatePop;
    IBOutlet NSTextField* wTextField;
    IBOutlet NSTextField* hTextField;
    IBOutlet NSMatrix* radioBtns;
    
@private
    int wStage;
    int hStage;
}

@property (nonatomic,readonly) NSString* rootObjectType;
@property (nonatomic,readonly) int templateType;
@property (nonatomic,readonly) int originPos;
@property (nonatomic,assign) int wStage;
@property (nonatomic,assign) int hStage;

- (IBAction)acceptSheet:(id)sender;
- (IBAction)cancelSheet:(id)sender;
- (IBAction)changedRootObject:(id)sender;

@end
