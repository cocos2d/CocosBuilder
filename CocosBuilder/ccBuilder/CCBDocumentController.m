//
//  CCBDocumentController.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 10/9/12.
//
//

#import "CCBDocumentController.h"

@implementation CCBDocumentController

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    NSLog(@"created controller: %@", self);
    
    return self;
}

- (void)noteNewRecentDocument:(NSDocument *)document
{
    NSLog(@"noteNewRecentDocument: %@", document);
}

@end
