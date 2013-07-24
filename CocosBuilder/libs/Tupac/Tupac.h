/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

enum {
    kTupacImageFormatPNG,
    kTupacImageFormatPNG_8BIT,
    kTupacImageFormatPVR_RGBA8888,
    kTupacImageFormatPVR_RGBA4444,
    kTupacImageFormatPVR_RGB565,
    kTupacImageFormatPVRTC_4BPP,
    kTupacImageFormatPVRTC_2BPP,
    kTupacImageFormatWEBP
};

@interface Tupac : NSObject 

@property(nonatomic) BOOL border;
@property(nonatomic) CGFloat scale;
@property(nonatomic, copy) NSArray *filenames;
@property(nonatomic, copy) NSString *outputName;
@property(nonatomic, copy) NSString *outputFormat;
@property(nonatomic,assign) int imageFormat;
@property(nonatomic,copy) NSString* directoryPrefix;
@property(nonatomic,assign) int maxTextureSize;
@property(nonatomic,assign) int padding;
@property(nonatomic,assign) BOOL dither;
@property(nonatomic,assign) BOOL compress;

+ (Tupac*) tupac;

- (void) createTextureAtlasFromDirectoryPaths:(NSArray *)dirs;
- (void)createTextureAtlas;

@end

extern NSString *TupacOutputFormatCocos2D;
extern NSString *TupacOutputFormatAndEngine;
