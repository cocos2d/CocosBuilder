//
//  Tupac.m
//  tupac
//
//  Created by Mark Onyschuk on 11-09-09.
//  Copyright 2011 Zynga Toronto, Inc. All rights reserved.
//

#import "Tupac.h"
//#import "TexturePacker.h"
#import "MaxRectsBinPack.h"
#import "vector"

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGImage.h>

#import "pvrtc.h"

unsigned long upper_power_of_two(unsigned long v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}

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
    //TEXTURE_PACKER::TexturePacker* tp; // we hide this ivar in the implementation - requires LLVM Compiler 2.x
}

@synthesize scale=scale_, border=border_, filenames=filenames_, outputName=outputName_, outputFormat=outputFormat_, imageFormat=imageFormat_, directoryPrefix=directoryPrefix_, maxTextureSize=maxTextureSize_, padding=padding_;

+ (Tupac*) tupac
{
    return [[[Tupac alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        scale_ = 1.0;
        border_ = NO;
        imageFormat_ = kTupacImageFormatPNG;
        self.outputFormat = TupacOutputFormatCocos2D;
        self.maxTextureSize = 2048;
        self.padding = 1;
        
        //tp = TEXTURE_PACKER::createTexturePacker();
    }
    return self;
}

- (void)dealloc {
    //TEXTURE_PACKER::releaseTexturePacker(tp);
    
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
        [rotateTF rotateByDegrees: (clockwise) ? 90 : -90];
        [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
        [rotateTF concat];
        
        NSRect rotatedRect = NSMakeRect(0, 0, rotatedSize.height, rotatedSize.width);
        [existingImage drawInRect:rotatedRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

- (NSRect) trimmedRectForImage:(CGImageRef)image
{
    int w = (int)CGImageGetWidth(image);
    int h = (int)CGImageGetHeight(image);
    
    int bytesPerRow = (int)CGImageGetBytesPerRow(image);
    int pixelsPerRow = bytesPerRow/4;
    
    CGImageGetDataProvider((CGImageRef)image);
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(image));
    const UInt32 *pixels = (const UInt32*)CFDataGetBytePtr(imageData);
    
    //NSLog(@"bitsperpixel: %d bytesPerRow: %d", (int)CGImageGetBitsPerPixel(image), (int)CGImageGetBytesPerRow(image));
    
    // Search from left
    int x;
    for (x = 0; x < w; x++)
    {
        BOOL emptyRow = YES;
        for (int y = 0; y < h; y++)
        {
            if (pixels[y*pixelsPerRow+x] & 0xff000000)
            {
                emptyRow = NO;
            }
        }
        if (!emptyRow) break;
    }
    
    // Search from right
    int xRight;
    for (xRight = w-1; xRight >= 0; xRight--)
    {
        BOOL emptyRow = YES;
        for (int y = 0; y < h; y++)
        {
            if (pixels[y*pixelsPerRow+xRight] & 0xff000000)
            {
                emptyRow = NO;
            }
        }
        if (!emptyRow) break;
    }
    
    // Search from bottom
    int y;
    for (y = 0; y < h; y++)
    {
        BOOL emptyRow = YES;
        for (int x = 0; x < w; x++)
        {
            if (pixels[y*pixelsPerRow+x] & 0xff000000)
            {
                emptyRow = NO;
            }
        }
        if (!emptyRow) break;
    }
    
    // Search from top
    int yTop;
    for (yTop = h-1; yTop >=0; yTop--)
    {
        BOOL emptyRow = YES;
        for (int x = 0; x < w; x++)
        {
            if (pixels[yTop*pixelsPerRow+x] & 0xff000000)
            {
                emptyRow = NO;
            }
        }
        if (!emptyRow) break;
    }
    
    int wTrimmed = xRight-x+1;
    int hTrimmed = yTop-y+1;
    
    CFRelease(imageData);
    
    return NSMakeRect(x, y, wTrimmed, hTrimmed);
}

- (void)createTextureAtlas
{
    // Create output directory if it doesn't exist
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* outputDir = [outputName_ stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:outputDir])
    {
        [fm createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    // Create atlas
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.filenames.count];
    NSMutableArray *imageInfos = [NSMutableArray arrayWithCapacity:self.filenames.count];
    
    for (NSString *filename in self.filenames) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:filename];
        if (image == nil) {
            fprintf(stderr, "unable to load image %s\n", [filename UTF8String]);
            exit(EXIT_FAILURE);
        }
        //NSBitmapImageRep* imageRep = [[image representations] objectAtIndex:0];
        
        
        // Load CGImage
        CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([filename cStringUsingEncoding:NSUTF8StringEncoding]);
        CGImageRef cgImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
        
        int w = (int)CGImageGetWidth(cgImage);
        int h = (int)CGImageGetHeight(cgImage);
        
        NSRect trimRect = [self trimmedRectForImage:cgImage];
        
        NSMutableDictionary* imageInfo = [NSMutableDictionary dictionary];
        [imageInfo setObject:[NSNumber numberWithInt:w] forKey:@"width"];
        [imageInfo setObject:[NSNumber numberWithInt:h] forKey:@"height"];
        [imageInfo setObject:[NSValue valueWithRect:trimRect] forKey:@"trimRect"];
        
        [imageInfos addObject:imageInfo];
        
        [image setFlipped:YES];
        [image setSize:NSMakeSize(w * self.scale, h * self.scale)];

        [images addObject:image];
        
        [image release];
        
        CGDataProviderRelease(dataProvider);
        CGImageRelease(cgImage);
    }
    
    if (![self.outputFormat isEqualToString:TupacOutputFormatCocos2D]
        && ![self.outputFormat isEqualToString:TupacOutputFormatAndEngine]) {
        fprintf(stderr, "unknown output format %s\n", [self.outputFormat UTF8String]);
        exit(EXIT_FAILURE);
    }

    /*
    tp->setTextureCount((int)[images count]);
    for (NSImage *image in images)
    {
        //NSLog(@"addTexture: %d x %d", (int)image.size.width, (int)image.size.height);
        tp->addTexture((int)image.size.width, (int)image.size.height);
    }*/
    
    int maxSideLen = 8;
    for (NSDictionary* imageInfo in imageInfos)
    {
        NSRect trimRect = [[imageInfo objectForKey:@"trimRect"] rectValue];
        
        int w = trimRect.size.width;
        if (w > maxSideLen) maxSideLen = w + self.padding * 2;
        
        int h = trimRect.size.height;
        if (h > maxSideLen) maxSideLen = h + self.padding * 2;
    }
    
    maxSideLen = upper_power_of_two(maxSideLen);
    
    // Create bin
    int outW = maxSideLen;
    int outH = 8;
    
    
    std::vector<TPRect> outRects;
    
    BOOL allFitted = NO;
    while (outW <= self.maxTextureSize && !allFitted)
    {
        MaxRectsBinPack bin(outW, outH);
        
        std::vector<TPRectSize> inRects;
        
        int numImages = 0;
        for (NSDictionary* imageInfo in imageInfos)
        {
            NSRect trimRect = [[imageInfo objectForKey:@"trimRect"] rectValue];
            
            inRects.push_back(TPRectSize());
            inRects[numImages].width = trimRect.size.width + self.padding * 2;
            inRects[numImages].height = trimRect.size.height + self.padding * 2;
            inRects[numImages].idx = numImages;
            
            numImages++;
        }
       
        bin.Insert(inRects, outRects, MaxRectsBinPack::RectBestShortSideFit);
        
        if (numImages == (int)outRects.size())
        {
            allFitted = YES;
        }
        else
        {
            outH *= 2;
            if (outH > self.maxTextureSize)
            {
                outH = 8;
                outW *= 2;
            }
        }
    }
    
    // Create the graphics
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
        while (index < outRects.size()) {
            
            
            bool rot = false;
            int  x, y, w, h;
            
            NSImage* image = [images objectAtIndex:outRects[index].idx];
            NSDictionary* imageInfo = [imageInfos objectAtIndex:outRects[index].idx];
            
            //rot = tp->getTextureLocation(index++, x, y, w, h);
            x = outRects[index].x;
            y = outRects[index].y;
           
            rot = outRects[index].rotated;
            
            x += self.padding;
            y += self.padding;
            
            NSLog(@"x: %d y: %d w: %d h: %d rot: %d", x, y, w, h, rot);
            
            NSRect trimRect = [[imageInfo objectForKey:@"trimRect"] rectValue];
            if (rot)
            {
                h = [[imageInfo objectForKey:@"width"] intValue];
                w = [[imageInfo objectForKey:@"height"] intValue];
                
                x -= (w - trimRect.origin.y - trimRect.size.height);
                y -= trimRect.origin.x;
            }
            else
            {
                w = [[imageInfo objectForKey:@"width"] intValue];
                h = [[imageInfo objectForKey:@"height"] intValue];
                
                x -= trimRect.origin.x;
                y -= trimRect.origin.y;
            }
            
            if (rot == true) image = [self rotateImage:image clockwise:YES];
            
            [image drawInRect:NSMakeRect(x, y, w, h) fromRect:NSZeroRect 
                    operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO 
                        hints:[NSDictionary dictionaryWithObjectsAndKeys:transform, NSImageHintCTM, nil]];
            
            index++;
        }
    }        
    [NSGraphicsContext restoreGraphicsState];
    
    NSString* textureFileName = NULL;

    if (imageFormat_ == kTupacImageFormatPNG)
    {
        //
        // PNG Export
        //
        
        NSString *pngFilename  = [self.outputName stringByAppendingPathExtension:@"png"];
        [[outRep representationUsingType:NSPNGFileType properties:nil] writeToFile:pngFilename atomically:YES];
        
        textureFileName = pngFilename;
    }
    else if (imageFormat_ == kTupacImageFormatPVR)
    {
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
        
        textureFileName = pvrFilename;
    }
        
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
        while(index < outRects.size())
        {
            // Get info about the image
            NSString* filename = [self.filenames objectAtIndex:outRects[index].idx];
            NSString* exportFilename = [filename lastPathComponent];
            if (directoryPrefix_) exportFilename = [directoryPrefix_ stringByAppendingPathComponent:exportFilename];
            NSDictionary* imageInfo = [imageInfos objectAtIndex:outRects[index].idx];
            
            bool rot = false;
            int x, y, w, h, wSrc, hSrc, xOffset, yOffset;
            x = outRects[index].x + self.padding;
            y = outRects[index].y + self.padding;
            w = outRects[index].width - self.padding*2;
            h = outRects[index].height - self.padding*2;
            wSrc = [[imageInfo objectForKey:@"width"] intValue];
            hSrc = [[imageInfo objectForKey:@"height"] intValue];
            NSRect trimRect = [[imageInfo objectForKey:@"trimRect"] rectValue];
            
            rot = outRects[index].rotated;
            
            if (rot)
            {
                int wRot = h;
                int hRot = w;
                w = wRot;
                h = hRot;
            }
            
            xOffset = trimRect.origin.x + trimRect.size.width/2 - wSrc/2;
            yOffset = -trimRect.origin.y - trimRect.size.height/2 + hSrc/2;
            
            index++;
            //rot = tp->getTextureLocation(index++, x, y, w, h);
            [frames setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               NSStringFromRect(NSMakeRect(x, y, w, h)),    @"frame",
                               NSStringFromPoint(NSMakePoint(xOffset, yOffset)),        @"offset",
                               [NSNumber numberWithBool:rot],               @"rotated",
                               NSStringFromRect(trimRect),                  @"sourceColorRect",
                               NSStringFromSize(NSMakeSize(wSrc, hSrc)),    @"sourceSize",
                               nil]
                       forKey:exportFilename];
        }
        
        [metadata setObject:textureFileName                                     forKey:@"realTextureFilename"];
        [metadata setObject:textureFileName                                     forKey:@"textureFilename"];
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

- (void) createTextureAtlasFromDirectoryPaths:(NSArray *)dirs
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Build a list of all file names from all directories
    NSMutableSet* allFiles = [NSMutableSet set];
    
    for (NSString* dir in dirs)
    {
        NSArray* files = [fm contentsOfDirectoryAtPath:dir error:NULL];
        
        for (NSString* file in files)
        {
            if ([[[file pathExtension] lowercaseString] isEqualToString:@"png"])
            {
                [allFiles addObject:[file lastPathComponent]];
            }
        }
    }
    
    // Add all the absolute file names to an array from the correct directories
    NSMutableArray* absoluteFilepaths = [NSMutableArray array];
    for (NSString* file in allFiles)
    {
        for (NSString* dir in dirs)
        {
            NSString* absFilepath = [dir stringByAppendingPathComponent:file];
            
            if ([fm fileExistsAtPath:absFilepath])
            {
                [absoluteFilepaths addObject:absFilepath];
                //foundFile = YES;
                break;
            }
        }
    }
    
    NSLog(@"Tupac filenames: %@", absoluteFilepaths);
    
    // Generate the sprite sheet
    self.filenames = absoluteFilepaths;
    [self createTextureAtlas];
}
@end

NSString *TupacOutputFormatCocos2D = @"cocos2d";
NSString *TupacOutputFormatAndEngine = @"andengine";
