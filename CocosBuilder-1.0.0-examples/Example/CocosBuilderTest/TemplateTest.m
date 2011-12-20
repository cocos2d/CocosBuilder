//
//  TemplateTest.m
//  CocosBuilderTest
//
//  Created by Viktor Lidholt on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TemplateTest.h"


@implementation TemplateTest

- (id) initWithProperties:(id)properties
{
    self = [super initWithFile:@"logo.png"];
    if (!self) return NULL;
    
    NSLog(@"properties=%@",properties);
    
    return self;
}

- (void) didLoadFromCCB
{
    NSLog(@"TemplateTest didLoadFromCCB");
}

@end
