//
//  Tupac.h
//  tupac
//
//  Created by Mark Onyschuk on 11-09-09.
//  Copyright 2011 Zynga Toronto, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kTupacImageFormatPNG,
    kTupacImageFormatPVR,
};

@interface Tupac : NSObject 

@property(nonatomic) BOOL border;
@property(nonatomic) CGFloat scale;
@property(nonatomic, copy) NSArray *filenames;
@property(nonatomic, copy) NSString *outputName;
@property(nonatomic, copy) NSString *outputFormat;
@property(nonatomic,assign) int imageFormat;

+ (Tupac*) tupac;

- (void) createTextureAtlasFromDirectoryPaths:(NSArray *)dirs;
- (void)createTextureAtlas;

@end

extern NSString *TupacOutputFormatCocos2D;
extern NSString *TupacOutputFormatAndEngine;
