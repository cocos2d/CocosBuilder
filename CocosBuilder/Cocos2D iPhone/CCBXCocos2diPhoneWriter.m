//
//  CCBXCocos2diPhoneWriter.m
//  CocosBuilder
//
//  Created by Viktor Lidholt on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBXCocos2diPhoneWriter.h"

@implementation CCBXCocos2diPhoneWriter

@synthesize data;

- (void) setupPropTypes
{
    propTypes = [[NSMutableArray alloc] init];
    
    [propTypes addObject:@"Position"];
    [propTypes addObject:@"Size"];
    [propTypes addObject:@"Point"];
    [propTypes addObject:@"PointLock"];
    [propTypes addObject:@"ScaleLock"];
    [propTypes addObject:@"Degrees"];
    [propTypes addObject:@"Integer"];
    [propTypes addObject:@"Float"];
    [propTypes addObject:@"FloatVar"];
    [propTypes addObject:@"Check"];
    [propTypes addObject:@"SpriteFrame"];
    [propTypes addObject:@"Texture"];
    [propTypes addObject:@"Byte"];
    [propTypes addObject:@"Color3"];
    [propTypes addObject:@"Color4FVar"];
    [propTypes addObject:@"Flip"];
    [propTypes addObject:@"Blendmode"];
    [propTypes addObject:@"FntFile"];
    [propTypes addObject:@"Text"];
    [propTypes addObject:@"FontTTF"];
    [propTypes addObject:@"IntegerLabeled"];
    [propTypes addObject:@"Block"];
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    data = [[NSMutableData alloc] init];
    stringCacheLookup = [[NSMutableDictionary alloc] init];
    [self setupPropTypes];
    
    return self;
}

- (void) dealloc
{
    [data release];
    [propTypes release];
    [super dealloc];
}

- (int) propTypeIdForName:(NSString*)prop
{
    NSInteger propType = [propTypes indexOfObject:prop];
    if (propType == NSNotFound) return -1;
    return (int)propType;
}

- (void) addToStringCache:(NSString*) str
{
    // Check if it is already in the chache, if so add to it's count
    NSNumber* num = [stringCacheLookup objectForKey:str];
    if (num)
    {
        num = [NSNumber numberWithInt:[num intValue]+1];
    }
    else
    {
        num = [NSNumber numberWithInt:1];
    }
    [stringCacheLookup setObject:num forKey:str];
}

- (void) writeBool:(BOOL)b
{
    unsigned char bytes[1];
    
    if (b) bytes[0] = 1;
    else bytes[0] = 0;
    
    [data appendBytes:bytes length:1];
}

- (void) writeByte:(unsigned char)b
{
    [data appendBytes:&b length:1];
}

- (void) clearTempBuffer
{
    for (int i = 0; i < kCCBXTempBufferSize; i++) temp[i] = 0;
    tempBit = 0;
    tempByte = 0;
}

- (void) putBit:(BOOL)b
{
    if (b) temp[tempByte] |= 1 << tempBit;
    
    tempBit++;
    if (tempBit >= 8)
    {
        tempByte++;
        tempBit = 0;
    }
}

- (void) flushBits
{
    int numBytes = tempByte;
    if (tempBit != 0) numBytes++;
    
    [data appendBytes:temp length:numBytes];
}

// Encode integers using Elias Gamma encoding, pad with zeros up to next
// even byte. Handle negative values using bijection.
- (void) writeInt:(int)d withSign:(BOOL) sign
{
    [self clearTempBuffer];
    
    unsigned long long num;
    if (sign)
    {
        // Support for signed numbers
        long long dl = d;
        long long bijection;
        if (d < 0) bijection = (-dl)*2;
        else bijection = dl*2+1;
        num = bijection;
    }
    else
    {
        // Support for 0
        num = d+1;
    }
    
    NSAssert(num > 0, @"ccbi export: Trying to store negative int as unsigned");
    
    // Write number of bits used
    int l = log2(num);
    
    for (int a = 0; a < l; a++)
    {
        [self putBit:NO];
    }
    [self putBit:YES];
    
    // Write the actual number
    for (int a=l-1; a >= 0; a--)
    {
        if (num & 1 << a) [self putBit:YES];
        else [self putBit:NO];
    }
    [self flushBits];
}

- (void) writeFloat:(float)f
{
    unsigned char type;
    
    if (f == 0) type = kCCBXFloat0;
    else if (f == 1) type = kCCBXFloat1;
    else if (f == -1) type = kCCBXFloatMinus1;
    else if (f == 0.5f) type = kCCBXFloat05;
    else if (((int)f) == f) type = kCCBXFloatInteger;
    else type = kCCBXFloatFull;
    
    // Write the type
    [self writeByte:type];
    
    // Write the value
    if (type == kCCBXFloatInteger)
    {
        [self writeInt:f withSign:YES];
    }
    else if (type == kCCBXFloatFull)
    {
        [data appendBytes:&f length:4];
    }
}

- (void) writeUTF8:(NSString*)str
{
    unsigned long len = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSAssert(len < 65536, @"ccbi export: Trying to write too long string");
    
    // Write Length of string
    unsigned char bytesLen[2];
    bytesLen[0] = (len >> 8) & 0xff;
    bytesLen[1] = len & 0xff;
    [data appendBytes:bytesLen length:2];
    
    // Write String as UTF8
    NSData *dataStr = [NSData dataWithBytes:[str UTF8String] length:len];
    [data appendData:dataStr];
}

- (void) writeCachedString:(NSString*) str
{
    NSNumber* num = [stringCacheLookup objectForKey:str];
    NSAssert(num, @"ccbi export: Trying to write string not added to cache");
    
    [self writeInt:[num intValue] withSign:NO];
}

- (void) writeProperty:(id) prop type:(NSString*)type name:(NSString*)name platform:(NSString*)platform
{
    int typeId = [self propTypeIdForName:type];
    NSAssert(typeId >= 0, @"ccbi export: Trying to write unkown property type %@",type);
    
    // Property type
    [self writeInt:typeId withSign:NO];
    
    // Property name
    [self writeCachedString:name];
    
    // Supported platforms
    if (!platform) [self writeByte:kCCBXPlatformAll];
    else if ([platform isEqualToString:@"iOS"])
    {
        NSLog(@"iOS platform property");
        [self writeByte:kCCBXPlatformIOS];
    }
    else if ([platform isEqualToString:@"Mac"])
    {
        NSLog(@"Mac platform property");
        [self writeByte:kCCBXPlatformMac];
    }
    else
    {
        NSLog(@"ccbi export: Unknown platform for property");
        [self writeByte:kCCBXPlatformAll];
    }
    
    NSLog(@" - %@",name);
    
    if ([type isEqualToString:@"Position"]
        || [type isEqualToString:@"Size"]
        || [type isEqualToString:@"Point"]
        || [type isEqualToString:@"PointLock"]
        || [type isEqualToString:@"ScaleLock"]
        || [type isEqualToString:@"FloatVar"])
    {
        float a = [[prop objectAtIndex:0] floatValue];
        float b = [[prop objectAtIndex:1] floatValue];
        [self writeFloat:a];
        [self writeFloat:b];
    }
    else if ([type isEqualToString:@"Degrees"]
             || [type isEqualToString:@"Float"])
    {
        float a = [prop floatValue];
        [self writeFloat:a];
    }
    else if ([type isEqualToString:@"Integer"]
             || [type isEqualToString:@"IntegerLabeled"])
    {
        int a = [prop intValue];
        [self writeInt:a withSign:YES];
    }
    else if ([type isEqualToString:@"Byte"])
    {
        int a = [prop intValue];
        [self writeByte:a];
    }
    else if ([type isEqualToString:@"Check"])
    {
        BOOL a = [prop boolValue];
        [self writeBool:a];
    }
    else if ([type isEqualToString:@"SpriteFrame"])
    {
        NSString* a = [prop objectAtIndex:0];
        NSString* b = [prop objectAtIndex:1];
        [self writeCachedString:a];
        [self writeCachedString:b];
    }
    else if ([type isEqualToString:@"Block"])
    {
        NSString* a = [prop objectAtIndex:0];
        NSNumber* b = [prop objectAtIndex:1];
        [self writeCachedString:a];
        [self writeInt:[b intValue] withSign:NO];
    }
    else if ([type isEqualToString:@"Texture"]
             || [type isEqualToString:@"FntFile"]
             || [type isEqualToString:@"Text"]
             || [type isEqualToString:@"FontTTF"])
    {
        [self writeCachedString:prop];
    }
    else if ([type isEqualToString:@"Color3"])
    {
        int a = [[prop objectAtIndex:0] intValue];
        int b = [[prop objectAtIndex:1] intValue];
        int c = [[prop objectAtIndex:2] intValue];
        [self writeByte:a];
        [self writeByte:b];
        [self writeByte:c];
    }
    else if ([type isEqualToString:@"Color4FVar"])
    {
        for (int i = 0; i < 2; i++)
        {
            NSArray* color = [prop objectAtIndex:i];
            for (int j = 0; j < 4; j++)
            {
                float comp = [[color objectAtIndex:j] floatValue];
                [self writeFloat:comp];
            }
        }
    }
    else if ([type isEqualToString:@"Flip"])
    {
        BOOL a = [[prop objectAtIndex:0] boolValue];
        BOOL b = [[prop objectAtIndex:1] boolValue];
        [self writeBool:a];
        [self writeBool:b];
    }
    else if ([type isEqualToString:@"Blendmode"])
    {
        int a = [[prop objectAtIndex:0] intValue];
        int b = [[prop objectAtIndex:1] intValue];
        [self writeInt:a withSign:NO];
        [self writeInt:b withSign:NO];
    }
}

- (void) cacheStringsForNode:(NSDictionary*) node
{
    // Basic data
    [self addToStringCache:[node objectForKey:@"baseClass"]];
    [self addToStringCache:[node objectForKey:@"customClass"]];
    [self addToStringCache:[node objectForKey:@"memberVarAssignmentName"]];
    
    // Properties
    NSArray* props = [node objectForKey:@"properties"];
    for (int i = 0; i < [props count]; i++)
    {
        NSDictionary* prop = [props objectAtIndex:i];
        [self addToStringCache:[prop objectForKey:@"name"]];
        id value = [prop objectForKey:@"value"];
        
        NSString* type = [prop objectForKey:@"type"];
        
        if ([type isEqualToString:@"SpriteFrame"])
        {
            [self addToStringCache:[value objectAtIndex:0]];
            [self addToStringCache:[value objectAtIndex:1]];
        }
        else if ([type isEqualToString:@"Block"])
        {
            [self addToStringCache:[value objectAtIndex:0]];
        }
        else if ([type isEqualToString:@"FontTTF"]
                 || [type isEqualToString:@"FntFile"]
                 || [type isEqualToString:@"Texture"]
                 || [type isEqualToString:@"Text"])
        {
            [self addToStringCache:value];
        }
    }
    
    // Children
    NSArray* children = [node objectForKey:@"children"];
    for (int i = 0; i < [children count]; i++)
    {
        [self cacheStringsForNode:[children objectAtIndex:i]];
    }
}

- (void) transformStringCache
{
    NSArray* stringCacheSorted = [stringCacheLookup keysSortedByValueUsingSelector:@selector(compare:)];
    
    NSMutableArray* stringCacheSortedReverse = [NSMutableArray arrayWithCapacity:[stringCacheSorted count]];
    
    NSEnumerator *enumerator = [stringCacheSorted reverseObjectEnumerator];
    for (id element in enumerator) {
        [stringCacheSortedReverse addObject:element];
    }
    
    // Clear the old cache and replace it with the new
    [stringCacheLookup removeAllObjects];
    
    for (int i = 0; i < [stringCacheSortedReverse count]; i++)
    {
        NSString* str = [stringCacheSortedReverse objectAtIndex:i];
        [stringCacheLookup setObject:[NSNumber numberWithInt:i] forKey:str];
    }
    
    stringCache = [stringCacheSortedReverse retain];
}

- (void) writeHeader
{
    // Magic number
    int magic = 'ccbi';
    [data appendBytes:&magic length:4];
    
    // Version
    [self writeInt:kCCBXVersion withSign:NO];
}

- (void) writeStringCache
{
    [self writeInt:(int)[stringCache count] withSign:NO];
    
    for (int i = 0; i < [stringCache count]; i++)
    {
        [self writeUTF8:[stringCache objectAtIndex:i]];
    }
}

- (void) writeNodeGraph:(NSDictionary*)node
{
    // Write class
    NSString* class = [node objectForKey:@"customClass"];
    if (!class || [class isEqualToString:@""])
    {
        class = [node objectForKey:@"baseClass"];
    }
    [self writeCachedString:class];
    
    NSLog(@"writeNodeGraph class: %@",class);
    
    // Write assignment type and name
    int memberVarAssignmentType = [[node objectForKey:@"memberVarAssignmentType"] intValue];
    [self writeInt:memberVarAssignmentType withSign:NO];
    if (memberVarAssignmentType)
    {
        [self writeCachedString:[node objectForKey:@"memberVarAssignmentName"]];
    }
    
    // Write properties
    NSArray* props = [node objectForKey:@"properties"];
    [self writeInt:(int)[props count] withSign:NO];
    for (int i = 0; i < [props count]; i++)
    {
        NSDictionary* prop = [props objectAtIndex:i];
        [self writeProperty:[prop objectForKey:@"value"] type:[prop objectForKey:@"type"] name:[prop objectForKey:@"name"] platform:[prop objectForKey:@"platform"]];
    }
    
    // Write children
    NSArray* children = [node objectForKey:@"children"];
    [self writeInt:(int)[children count] withSign:NO];
    for (int i = 0; i < [children count]; i++)
    {
        [self writeNodeGraph:[children objectAtIndex:i]];
    }
}

- (void) writeDocument:(NSDictionary*)doc
{
    NSDictionary* nodeGraph = [doc objectForKey:@"nodeGraph"];
    
    [self cacheStringsForNode:nodeGraph];
    [self transformStringCache];
    
    [self writeHeader];
    [self writeStringCache];
    [self writeNodeGraph:nodeGraph];
}

@end
