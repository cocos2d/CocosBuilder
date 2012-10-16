//
//  CCBSplitHorizontalView.h
//  CocosBuilder
//
//  Created by Aris Tzoumas on 16/10/12.
//
//

#import <Cocoa/Cocoa.h>

@interface CCBSplitHorizontalView : NSSplitView <NSSplitViewDelegate>
{
    IBOutlet NSView* topView;
    IBOutlet NSView* bottomView;
}

-(void) toggleBottomView:(BOOL)show;

@end
