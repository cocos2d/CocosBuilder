//
//  Tupac.m
//  tupac
//
//  Created by Mark Onyschuk on 11-09-09.
//  Copyright 2011 Zynga Toronto, Inc. All rights reserved.
//

#import "Tupac.h"
#import "TexturePacker.h"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "pvrtc.h"

typedef struct _PVRTexHeader
{
    uint32_t headerLength;
    uint32_t height;
    uint32_t width;
    uint32_t numMipmaps;
    uint32_t flags;
    uint32_t dataLength;
    uint32_t bpp;
    uint32_t bitmaskRed;
    uint32_t bitmaskGreen;
    uint32_t bitmaskBlue;
    uint32_t bitmaskAlpha;
    uint32_t pvrTag;
    uint32_t numSurfs;
} PVRTexHeader;

@implementation Tupac {
    TEXTURE_PACKER::TexturePacker* tp; // we hide this ivar in the implementation - requires LLVM Compiler 2.x
}

@synthesize scale=scale_, border=border_, filenames=filenames_, outputName=outputName_, outputFormat=outputFormat_;

- (id)init {
    if ((self = [super init])) {
        scale_ = 1.0;
        border_ = NO;
        
        tp = TEXTURE_PACKER::createTexturePacker();
    }
    return self;
}

- (void)dealloc {
    TEXTURE_PACKER::releaseTexturePacker(tp);
    
    [filenames_ release];
    [outputName_ release];
    [outputFormat_ release];
    
    [super dealloc];
}

- (NSImage *)rotateImage:(NSImage *)image clockwise:(BOOL)clockwise {
    NSImage *existingImage = image;
    NSSize  existingSize = [existingImage size];
    
    NSSize  rotatedSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:rotatedSize];
    
    [rotatedImage lockFocus];
    {
        /**
         * Apply the following transformations:
         *
         * - bring the rotation point to the centre of the image instead of
         *   the default lower, left corner (0,0).
         * - rotate it by 90 degrees, either clock or counter clockwise.
         * - re-translate the rotated image back down to the lower left corner
         *   so that it appears in the right place.
         */
        NSAffineTransform *rotateTF = [NSAffineTransform transform];
        NSPoint centerPoint = NSMakePoint(rotatedSize.width / 2, rotatedSize.height / 2);
        
        [rotateTF translateXBy: centerPoint.x yBy: centerPoint.y];
        [rotateTF rotateByDegrees: (clockwise) ? - 90 : 90];
        [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
        [rotateTF concat];
        
        NSRect rotatedRect = NSMakeRect(0, 0, rotatedSize.height, rotatedSize.width);
        [existingImage drawInRect:rotatedRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

- (void)createTextureAtlas {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.filenames.count];
    
    for (NSString *filename in self.filenames) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:filename];
        if (image == nil) {
            fprintf(stderr, "unable to load image %s\n", [filename UTF8String]);
            exit(EXIT_FAILURE);
        }
        
        [image setFlipped:YES];
        [image setSize:NSMakeSize(image.size.width * self.scale, image.size.height * self.scale)];

        [images addObject:image];
        
        [image release];
    }
    
    if (![self.outputFormat isEqualToString:TupacOutputFormatCocos2D]
        && ![self.outputFormat isEqualToString:TupacOutputFormatAndEngine]) {
        fprintf(stderr, "unknown output format %s\n", [self.outputFormat UTF8String]);
        exit(EXIT_FAILURE);
    }

    tp->setTextureCount((int)[images count]);
    for (NSImage *image in images) tp->addTexture((int)image.size.width, (int)image.size.height);

    int outW, outH;
    if (tp->packTextures(outW, outH, true, self.border) == 0) {
        fprintf(stderr, "unable to pack images\n");
        exit(EXIT_FAILURE);
    }
        
    NSBitmapImageRep *outRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
                                                                       pixelsWide:outW
                                                                       pixelsHigh:outH 
                                                                    bitsPerSample:8 
                                                                  samplesPerPixel:4 
                                                                         hasAlpha:YES 
                                                                         isPlanar:NO 
                                                                   colorSpaceName:NSCalibratedRGBColorSpace 
                                                                     bitmapFormat:0 //NSAlphaFirstBitmapFormat
                                                                      bytesPerRow:(32 / 8) * outW
                                                                     bitsPerPixel:32];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:outRep]];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:1.0 yBy:-1.0];
    [transform translateXBy:0.0 yBy:-outH];
    [transform concat];
    
    // draw our individual images
    {
        int index = 0;
        for (NSImage *image in images) {
            bool rot;
            int  x, y, w, h;
            
            rot = tp->getTextureLocation(index++, x, y, w, h);
            
            if (rot == true) image = [self rotateImage:image clockwise:YES]; 
            
            [image drawInRect:NSMakeRect(x, y, w, h) fromRect:NSZeroRect 
                    operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO 
                        hints:[NSDictionary dictionaryWithObjectsAndKeys:transform, NSImageHintCTM, nil]];
        }
    }        
    [NSGraphicsContext restoreGraphicsState];

    //
    // PNG Export
    //
    
//    NSString *pngFilename  = [self.outputName stringByAppendingPathExtension:@"png"];
//    [[outRep representationUsingType:NSPNGFileType properties:nil] writeToFile:pngFilename atomically:YES];

    
    //
    // PVR Export
    //
    
    pvrtc_info_output(stdout);

    size_t pvrOutputSize    = pvrtc_size((int)outRep.pixelsWide,    // width
                                         (int)outRep.pixelsHigh,    // height
                                         0,                         // generate mipmaps
                                         0);                        // use 2bpp compression
    
    NSMutableData *pvrData  = [[NSMutableData alloc] initWithLength:pvrOutputSize];
    NSString      *pvrFilename = [self.outputName stringByAppendingPathExtension:@"pvr"];
    
    if (outW == outH) {
        // if square, we use PVRC (compressed) format for our data

        pvrtc_compress([outRep bitmapData],     // input data
                       [pvrData mutableBytes],  // output data
                       (int)outRep.pixelsWide,  // resize width
                       (int)outRep.pixelsHigh,  // resize height
                       0,                       // generate mipmaps
                       1,                       // alpha on
                       0,                       // texture wraps
                       0);                      // use 2bpp compression
    }
    else {
        // if not square, we construct a file with a simple header followed by uncompressed data

        PVRTexHeader header;
        
        header.headerLength = sizeof(PVRTexHeader);

        header.width = (uint32_t)outRep.pixelsWide;
        header.height = (uint32_t)outRep.pixelsHigh;
        
        header.numMipmaps = 0;
        
        header.bpp = 32;
        header.flags = 32786;
        header.dataLength = (uint32_t)(outRep.pixelsWide * outRep.pixelsHigh * 4);

        header.bitmaskRed   = 0xFF000000;
        header.bitmaskBlue  = 0x0000FF00;
        header.bitmaskGreen = 0x00FF0000;
        header.bitmaskAlpha = 0x000000FF;
        
        header.pvrTag       = 559044176;
        
        header.numSurfs     = 1;
        
        [pvrData setLength:0];
        [pvrData appendBytes:&header length:sizeof(PVRTexHeader)];
        [pvrData appendBytes:[outRep bitmapData] length:outRep.pixelsWide * outRep.pixelsHigh * 4];
    }
    
    [pvrData writeToFile:pvrFilename atomically:YES];
    [pvrData release];

    [outRep release];
    
    // 
    // Metadata File Export
    //
    
    if ([self.outputFormat isEqualToString:TupacOutputFormatCocos2D]) {
        NSMutableDictionary *outDict    = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        NSMutableDictionary *frames     = [NSMutableDictionary dictionaryWithCapacity:self.filenames.count];
        NSMutableDictionary *metadata   = [NSMutableDictionary dictionaryWithCapacity:4];
        
        [outDict setObject:frames   forKey:@"frames"];
        [outDict setObject:metadata forKey:@"metadata"];
        
        int index = 0;
        for (NSString *filename in self.filenames) {
            bool rot;
            int x, y, w, h;
            rot = tp->getTextureLocation(index++, x, y, w, h);
            [frames setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               NSStringFromRect(NSMakeRect(x, y, w, h)),    @"frame",
                               NSStringFromPoint(NSMakePoint(0, 0)),        @"offset",
                               [NSNumber numberWithBool:rot],               @"rotated",
                               NSStringFromRect(NSMakeRect(x, y, w, h)),    @"sourceColorRect",
                               NSStringFromSize(NSMakeSize(w, h)),          @"sourceSize",
                               nil]
                       forKey:[filename lastPathComponent]];
        }
        
        [metadata setObject:pvrFilename                                     forKey:@"realTextureFilename"];
        [metadata setObject:pvrFilename                                     forKey:@"textureFilename"];
        [metadata setObject:[NSNumber numberWithInt:2]                      forKey:@"format"];
        [metadata setObject:NSStringFromSize(NSMakeSize(outW, outH))        forKey:@"size"];
        
        [outDict writeToFile:[self.outputName stringByAppendingPathExtension:@"plist"] atomically:YES];
        [outDict release];
    }
    else if ([self.outputFormat isEqualToString:TupacOutputFormatAndEngine]) {
        fprintf(stderr, "[MO] output format %s not yet supported\n", [self.outputFormat UTF8String]);
        exit(EXIT_FAILURE);
    }
}
@end

NSString *TupacOutputFormatCocos2D = @"cocos2d";
NSString *TupacOutputFormatAndEngine = @"andengine";
