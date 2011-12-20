//
//  Copyright 2011 Viktor Lidholt. All rights reserved.
//

#import "AssetsItem.h"


@implementation AssetsItem

@synthesize spriteFile, spriteSheetFile, cachedImage;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithSpriteFile:(NSString*) file
{
    self = [super init];
    if (!self) return NULL;
    
    //CCSprite* sprt = [CCSprite spriteWithFile:@""];
    self.spriteFile = file;
    
    return self;
}

- (id) initWithSpriteSheet:(NSString *)sheetFile frameName:(NSString*)file
{
    self = [super init];
    if (!self) return NULL;
    
    self.spriteFile = file;
    self.spriteSheetFile = sheetFile;
    
    return self;
}

- (void)dealloc
{
    self.spriteFile = NULL;
    self.spriteSheetFile = NULL;
    self.cachedImage = NULL;
    [title release];
    [super dealloc];
}

- (NSRect)rescaleRect:(NSRect)rect toFitInSize:(NSSize)size
{
    if (rect.size.width < size.width && rect.size.height < size.height)
    {
        return rect;
    }
    
	float heightQuotient = rect.size.height / size.height;
	float widthQuotient = rect.size.width / size.width;
	
	if(heightQuotient > widthQuotient)
		return NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width / heightQuotient, rect.size.height / heightQuotient);
	else
		return NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width / widthQuotient, rect.size.height / widthQuotient);
}

- (void) createThumbNailFromImage:(NSImage*)src
{
    [src setScalesWhenResized:YES];
    
    self.cachedImage = [[[NSImage alloc] initWithSize:NSMakeSize(50, 50)] autorelease];
    
    NSRect dstRect = NSMakeRect(0, 0, [src size].width, [src size].height);
    dstRect = [self rescaleRect:dstRect toFitInSize:NSMakeSize(50, 50)];
    
    dstRect.origin.x = (int)((50-dstRect.size.width)/2);
    dstRect.origin.y = (int)((50-dstRect.size.height)/2);
    
    [cachedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [src setSize:dstRect.size];
    [src compositeToPoint:dstRect.origin operation:NSCompositeCopy];
    [cachedImage unlockFocus];
}

static NSImage* cachedSpriteSheetImage = NULL;
static NSString* cachedSpriteSheetImageName = @"";

- (id) imageRepresentation
{
    if (cachedImage) return cachedImage;
    
    if (spriteSheetFile)
    {
        // TODO: Fix
        NSString* assetsPath = [spriteSheetFile stringByDeletingLastPathComponent];
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:spriteSheetFile];
        
        NSString* imgFile = [[dict objectForKey:@"metadata"] objectForKey:@"textureFileName"];
        
        NSString* absImgFile = [NSString stringWithFormat:@"%@/%@", assetsPath,imgFile];
        
        NSImage* tex;
        if ([absImgFile isEqualToString:cachedSpriteSheetImageName])
        {
            tex = cachedSpriteSheetImage;
        }
        else
        {
            if (cachedSpriteSheetImage)
            {
                [cachedSpriteSheetImage release];
                cachedSpriteSheetImage = NULL;
                [cachedSpriteSheetImageName release];
                cachedSpriteSheetImageName = NULL;
            }
            
            NSImageRep* imgRep = [NSImageRep imageRepWithContentsOfFile:absImgFile];
        
            if (![imgRep isKindOfClass:[NSBitmapImageRep class]]) return NULL;
            NSBitmapImageRep* bitmapRep = (NSBitmapImageRep*) imgRep;
                
            tex = [[NSImage alloc] initWithSize:NSMakeSize([bitmapRep pixelsWide], [bitmapRep pixelsHigh])];
            [tex addRepresentation:bitmapRep];
            [tex setFlipped:YES];
            
            cachedSpriteSheetImage = tex;
            [cachedSpriteSheetImage retain];
            cachedSpriteSheetImageName = absImgFile;
            [cachedSpriteSheetImageName retain];
        }
        
        
        
        NSDictionary* dictFrames = [dict objectForKey:@"frames"];
        NSDictionary* frameInfo = [dictFrames objectForKey:spriteFile];
        if (!frameInfo) return NULL;
        
        NSRect rect = NSRectFromString([frameInfo objectForKey:@"frame"]);
        BOOL rotated = [[frameInfo objectForKey:@"rotated"] boolValue];
        if (rotated)
        {
            rect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
        }
        
        NSImage* imgFrame;
        if (rotated)
        {
            imgFrame = [[NSImage alloc] initWithSize:NSMakeSize(rect.size.height, rect.size.width)];
        }
        else
        {
            imgFrame = [[NSImage alloc] initWithSize:rect.size];
        }
        [imgFrame setFlipped:YES];
        [imgFrame lockFocus];
        
        if (rotated)
        {
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform rotateByDegrees:-90];
            [transform concat];
            
            [tex drawAtPoint:NSMakePoint(-rect.size.width, 0 /*rect.size.height*/) fromRect:rect operation:NSCompositeCopy fraction:1];
        }
        else
        {
            [tex drawAtPoint:NSZeroPoint fromRect:rect operation:NSCompositeCopy fraction:1];
        }
        
        [imgFrame unlockFocus];
        
        [self createThumbNailFromImage:imgFrame];
    }
    else
    {
        NSImage* src = [[[NSImage alloc] initWithContentsOfFile:spriteFile] autorelease];
        [self createThumbNailFromImage:src];
    }
    
    return cachedImage;
}

- (NSString *) imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (NSString *) imageUID
{
    if (spriteSheetFile)
    {
        return [NSString stringWithFormat:@"%d:%@:%@",(int)version,spriteSheetFile,spriteFile];
    }
    return [NSString stringWithFormat:@"%d:%@",(int)version, spriteFile];
}

- (NSString *) imageTitle
{
    if (title) return title;
    else return [self.spriteFile lastPathComponent];
}

- (void) setImageVersion:(NSUInteger)v
{
    version = v;
}

- (void) setTitle:(NSString*)t
{
    title = t;
    [title retain];
}

/*
- (NSUInteger) imageVersion
{
    return version;
}
 */

@end
