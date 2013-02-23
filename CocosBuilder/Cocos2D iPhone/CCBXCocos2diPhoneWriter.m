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

#import "CCBXCocos2diPhoneWriter.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "CustomPropSetting.h"

@implementation CCBXCocos2diPhoneWriter

@synthesize data;
@synthesize flattenPaths;
@synthesize serializedProjectSettings;

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
    [propTypes addObject:@"Animation"];
    [propTypes addObject:@"CCBFile"];
    [propTypes addObject:@"String"];
    [propTypes addObject:@"BlockCCControl"];
    [propTypes addObject:@"FloatScale"];
    [propTypes addObject:@"FloatXY"];
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
    [stringCacheLookup release];
    [stringCache release];
    [serializedProjectSettings release];
    [super dealloc];
}

- (int) propTypeIdForName:(NSString*)prop
{
    NSInteger propType = [propTypes indexOfObject:prop];
    if (propType == NSNotFound) return -1;
    return (int)propType;
}

- (void) addToStringCache:(NSString*) str isPath:(BOOL) isPath
{
    if (isPath && flattenPaths)
    {
        str = [str lastPathComponent];
    }
    
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

- (void) writeCachedString:(NSString*) str isPath:(BOOL) isPath
{
    if (isPath && flattenPaths)
    {
        str = [str lastPathComponent];
    }
    
    NSNumber* num = [stringCacheLookup objectForKey:str];
    
    NSAssert(num, @"ccbi export: Trying to write string not added to cache (%@)", str);
    
    [self writeInt:[num intValue] withSign:NO];
}

- (BOOL) isSprite:(NSString*) sprite inGeneratedSpriteSheet: (NSString*) sheet
{
    if (!sheet || [sheet isEqualToString:@""])
    {
        NSString* proposedSheetName = [sprite stringByDeletingLastPathComponent];
        if ([[serializedProjectSettings objectForKey:@"generatedSpriteSheets"] objectForKey:proposedSheetName])
        {
            return YES;
        }
    }
    return NO;
}

- (void) writeProperty:(id) prop type:(NSString*)type name:(NSString*)name platform:(NSString*)platform
{
    int typeId = [self propTypeIdForName:type];
    NSAssert(typeId >= 0, @"ccbi export: Trying to write unkown property type %@",type);
    
    // Property type
    [self writeInt:typeId withSign:NO];
    
    // Property name
    [self writeCachedString:name isPath:NO];
    
    // Supported platforms
    if (!platform) [self writeByte:kCCBXPlatformAll];
    else if ([platform isEqualToString:@"iOS"])
    {
        [self writeByte:kCCBXPlatformIOS];
    }
    else if ([platform isEqualToString:@"Mac"])
    {
        [self writeByte:kCCBXPlatformMac];
    }
    else
    {
        [self writeByte:kCCBXPlatformAll];
    }
    
    if ([type isEqualToString:@"Position"])
    {
        float a = [[prop objectAtIndex:0] floatValue];
        float b = [[prop objectAtIndex:1] floatValue];
        int positionType = [[prop objectAtIndex:2] intValue];
        [self writeFloat:a];
        [self writeFloat:b];
        [self writeInt:positionType withSign:NO];
    }
    else if([type isEqualToString:@"Size"])
    {
        float a = [[prop objectAtIndex:0] floatValue];
        float b = [[prop objectAtIndex:1] floatValue];
        int sizeType = [[prop objectAtIndex:2] intValue];
        [self writeFloat:a];
        [self writeFloat:b];
        [self writeInt:sizeType withSign:NO];
    }
    else if ([type isEqualToString:@"Point"]
             || [type isEqualToString:@"PointLock"]
             || [type isEqualToString:@"FloatVar"]
             || [type isEqualToString:@"FloatXY"])
    {
        float a = [[prop objectAtIndex:0] floatValue];
        float b = [[prop objectAtIndex:1] floatValue];
        [self writeFloat:a];
        [self writeFloat:b];
    }
    else if ([type isEqualToString:@"ScaleLock"])
    {
        float a = [[prop objectAtIndex:0] floatValue];
        float b = [[prop objectAtIndex:1] floatValue];
        int scaleType = 0;
        NSNumber* scaleTypeNum = [prop objectAtIndex:3];
        if (scaleTypeNum) scaleType = [scaleTypeNum intValue];

        [self writeFloat:a];
        [self writeFloat:b];
        [self writeInt:scaleType withSign:NO];
    }
    else if ([type isEqualToString:@"Degrees"]
             || [type isEqualToString:@"Float"])
    {
        float a = [prop floatValue];
        [self writeFloat:a];
    }
    else if ([type isEqualToString:@"FloatScale"])
    {
        float f = [[prop objectAtIndex:0] floatValue];
        int type = [[prop objectAtIndex:1] intValue];
        [self writeFloat:f];
        [self writeInt:type withSign:NO];
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
        
        if ([self isSprite:b inGeneratedSpriteSheet:a])
        {
            a = [[b stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
        }
        
        [self writeCachedString:a isPath:YES];
        [self writeCachedString:b isPath:[a isEqualToString:@""]];
    }
    else if ([type isEqualToString:@"Animation"])
    {
        NSString* animationFile = [prop objectAtIndex:0];
        NSString* animation = [prop objectAtIndex:1];
        [self writeCachedString:animationFile isPath:YES];
        [self writeCachedString:animation isPath:NO];
    }
    else if ([type isEqualToString:@"Block"])
    {
        NSString* a = [prop objectAtIndex:0];
        NSNumber* b = [prop objectAtIndex:1];
        [self writeCachedString:a isPath:NO];
        [self writeInt:[b intValue] withSign:NO];
    }
    else if ([type isEqualToString:@"BlockCCControl"])
    {
        NSString* a = [prop objectAtIndex:0];
        NSNumber* b = [prop objectAtIndex:1];
        NSNumber* c = [prop objectAtIndex:2];
        [self writeCachedString:a isPath:NO];
        [self writeInt:[b intValue] withSign:NO];
        [self writeInt:[c intValue] withSign:NO];
    }
    else if ([type isEqualToString:@"Texture"]
             || [type isEqualToString:@"FntFile"]
             || [type isEqualToString:@"CCBFile"])
    {
        [self writeCachedString:prop isPath: YES];
    }
    else if ([type isEqualToString:@"Text"]
             || [type isEqualToString:@"String"]
             || [type isEqualToString:@"FontTTF"])
    {
        [self writeCachedString:prop isPath: NO];
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
    [self addToStringCache:@"" isPath:NO];
    [self addToStringCache:[node objectForKey:@"baseClass"] isPath:NO];
    [self addToStringCache:[node objectForKey:@"customClass"] isPath:NO];
    [self addToStringCache:[node objectForKey:@"memberVarAssignmentName"] isPath:NO];
    
    // Add JS controller class
    if (jsControlled)
    {
        NSString* jsController = [node objectForKey:@"jsController"];
        if (!jsController) jsController = @"";
        [self addToStringCache:jsController isPath:NO];
    }
    
    // Animated properties
    NSDictionary* animatedProps = [node objectForKey:@"animatedProperties"];
    for (NSString* seqIdStr in animatedProps)
    {
        NSDictionary* props = [animatedProps objectForKey:seqIdStr];
        for (NSString* propName in props)
        {
            NSMutableDictionary* prop = [props objectForKey:propName];
            int kfType = [[prop objectForKey:@"type"] intValue];
            if (kfType == kCCBKeyframeTypeSpriteFrame)
            {
                NSArray* keyframes = [prop objectForKey:@"keyframes"];
                for (NSDictionary* keyframe in keyframes)
                {
                    // Write a keyframe
                    id value = [keyframe objectForKey:@"value"];
                    NSString* a = [value objectAtIndex:1];
                    NSString* b = [value objectAtIndex:0];
                    
                    if ([b isEqualToString:@"Use regular file"]) b = @"";
                    if ([a isEqualToString:@"Use regular file"]) a = @"";
                    
                    if ([self isSprite:b inGeneratedSpriteSheet:a])
                    {
                        a = [[b stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
                    }
                    
                    [self addToStringCache:a isPath:YES];
                    [self addToStringCache:b isPath:[a isEqualToString:@""]];
                }
            }
        }
    }
    
    // Properties
    NSArray* props = [node objectForKey:@"properties"];
    for (int i = 0; i < [props count]; i++)
    {
        NSDictionary* prop = [props objectAtIndex:i];
        [self addToStringCache:[prop objectForKey:@"name"] isPath:NO];
        id value = [prop objectForKey:@"value"];
        
        NSString* type = [prop objectForKey:@"type"];
        
        id baseValue = [prop objectForKey:@"baseValue"];
        
        if (baseValue)
        {
            // We need to transform the base value to a normal value (base values override normal values)
            if ([type isEqualToString:@"Position"])
            {
                value = [NSArray arrayWithObjects:
                         [baseValue objectAtIndex:0],
                         [baseValue objectAtIndex:1],
                         [value objectAtIndex:2],
                         nil];
            }
            else if ([type isEqualToString:@"ScaleLock"])
            {
                value = [NSArray arrayWithObjects:
                         [baseValue objectAtIndex:0],
                         [baseValue objectAtIndex:1],
                         [NSNumber numberWithBool:NO],
                         [value objectAtIndex:3],
                         nil];
            }
            else if ([type isEqualToString:@"SpriteFrame"])
            {
                NSString* a = [baseValue objectAtIndex:0];
                NSString* b = [baseValue objectAtIndex:1];
                if ([b isEqualToString:@"Use regular file"]) b = @"";
                
                if ([self isSprite:a inGeneratedSpriteSheet:b])
                {
                    b = [[a stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
                }
                
                value = [NSArray arrayWithObjects:b, a, nil];
            }
            else
            {
                // Value needs no transformation
                value = baseValue;
            }
        }
        
        if ([type isEqualToString:@"SpriteFrame"])
        {
            NSString* a = [value objectAtIndex:0];
            NSString* b = [value objectAtIndex:1];
            
            if ([self isSprite:b inGeneratedSpriteSheet:a])
            {
                a = [[b stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
            }
            
            [self addToStringCache: a isPath:YES];
            [self addToStringCache:b isPath:[a isEqualToString:@""]];
        }
		else if( [type isEqualToString:@"Animation"])
		{
            [self addToStringCache:[value objectAtIndex:0] isPath:YES];
            [self addToStringCache:[value objectAtIndex:1] isPath:NO];			
		}
        else if ([type isEqualToString:@"Block"])
        {
            [self addToStringCache:[value objectAtIndex:0] isPath:NO];
        }
        else if ([type isEqualToString:@"BlockCCControl"])
        {
            [self addToStringCache:[value objectAtIndex:0] isPath:NO];
        }
        else if ([type isEqualToString:@"FntFile"]
                 || [type isEqualToString:@"Texture"]
                 || [type isEqualToString:@"CCBFile"])
        {
            [self addToStringCache:value isPath:YES];
        }
        else if ([type isEqualToString:@"Text"]
                 || [type isEqualToString:@"FontTTF"]
                 || [type isEqualToString:@"String"])
        {
            [self addToStringCache:value isPath:NO];
        }
    }
    
    // Custom properties
    NSArray* customProps = [node objectForKey:@"customProperties"];
    for (NSDictionary* customProp in customProps)
    {
        [self addToStringCache:[customProp objectForKey:@"name"] isPath:NO];
        
        int customType = [[customProp objectForKey:@"type"] intValue];
        if (customType == kCCBCustomPropTypeString)
        {
            [self addToStringCache:[customProp objectForKey:@"value"] isPath:NO];
        }
    }
    
    // Children
    NSArray* children = [node objectForKey:@"children"];
    for (int i = 0; i < [children count]; i++)
    {
        [self cacheStringsForNode:[children objectAtIndex:i]];
    }
}

- (void) cacheStringsForSequences:(NSDictionary*)doc
{
    NSArray* seqs = [doc objectForKey:@"sequences"];
    for (NSDictionary* seq in seqs)
    {
        [self addToStringCache:[seq objectForKey:@"name"] isPath:NO];
        
        // Write callback channel
        NSArray* callbackKeyframes = [[seq objectForKey:@"callbackChannel"] objectForKey:@"keyframes"];
        for (NSDictionary* kf in callbackKeyframes)
        {
            NSArray* value = [kf objectForKey:@"value"];
            NSString* callbackName = [value objectAtIndex:0];
            [self addToStringCache:callbackName isPath:NO];
        }
        
        NSArray* soundKeyframes = [[seq objectForKey:@"soundChannel"] objectForKey:@"keyframes"];
        for (NSDictionary* kf in soundKeyframes)
        {
            NSArray* value = [kf objectForKey:@"value"];
            NSString* soundName = [value objectAtIndex:0];
            [self addToStringCache:soundName isPath:YES];
        }
    }
}

- (void) writeChannelKeyframe:(NSDictionary*) kf
{
    NSArray* value = [kf objectForKey:@"value"];
    int type = [[kf objectForKey:@"type"] intValue];
    float time = [[kf objectForKey:@"time"] floatValue];
    
    [self writeFloat:time];
    
    if (type == kCCBKeyframeTypeCallbacks)
    {
        NSString* selector = [value objectAtIndex:0];
        int target = [[value objectAtIndex:1] intValue];
        
        [self writeCachedString:selector isPath:NO];
        [self writeInt:target withSign:NO];
    }
    else if (type == kCCBKeyframeTypeSoundEffects)
    {
        NSString* sound = [value objectAtIndex:0];
        float pitch = [[value objectAtIndex:1] floatValue];
        float pan = [[value objectAtIndex:2] floatValue];
        float gain = [[value objectAtIndex:3] floatValue];
        
        [self writeCachedString:sound isPath:YES];
        [self writeFloat:pitch];
        [self writeFloat:pan];
        [self writeFloat:gain];
    }
}

- (void) writeSequences:(NSDictionary*)doc
{
    NSArray* seqs = [doc objectForKey:@"sequences"];
    
    // Write number of sequences
    [self writeInt:(int)[seqs count] withSign:NO];
    
    int autoPlaySeqId = -1;
    
    // Write each sequence
    for (NSDictionary* seq in seqs)
    {
        [self writeFloat:[[seq objectForKey:@"length"] floatValue]];
        [self writeCachedString:[seq objectForKey:@"name"] isPath:NO];
        [self writeInt:[[seq objectForKey:@"sequenceId"] intValue] withSign:NO];
        [self writeInt:[[seq objectForKey:@"chainedSequenceId"] intValue] withSign:YES];
        
        // Check if autoplay is enabled
        if ([[seq objectForKey:@"autoPlay"] boolValue])
        {
            autoPlaySeqId = [[seq objectForKey:@"sequenceId"] intValue];
        }
        
        // Write callback channel
        NSArray* callbackKeyframes = [[seq objectForKey:@"callbackChannel"] objectForKey:@"keyframes"];
        
        [self writeInt: (int)callbackKeyframes.count withSign:NO];
        for (NSDictionary* keyframe in callbackKeyframes)
        {
            [self writeChannelKeyframe:keyframe];
        }
        
        // Write and sound channel
        NSArray* soundKeyframes = [[seq objectForKey:@"soundChannel"] objectForKey:@"keyframes"];
        
        [self writeInt: (int)soundKeyframes.count withSign:NO];
        for (NSDictionary* keyframe in soundKeyframes)
        {
            [self writeChannelKeyframe:keyframe];
        }
    }
    
    // Write autoPlay sequence (-1 for no autoplay)
    [self writeInt:autoPlaySeqId withSign:YES];
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
    
    // JavaScript or not
    [self writeBool:jsControlled];
}

- (void) writeStringCache
{
    [self writeInt:(int)[stringCache count] withSign:NO];
    
    for (int i = 0; i < [stringCache count]; i++)
    {
        [self writeUTF8:[stringCache objectAtIndex:i]];
    }
}

- (void) writeKeyframeValue:(id)value type: (NSString*)type time:(float)time easingType: (int)easingType easingOpt: (float)easingOpt
{
    // Write time
    [self writeFloat:time];
    
    // Write easing type
    [self writeInt:easingType withSign:NO];
    if (easingType == kCCBKeyframeEasingCubicIn
        || easingType == kCCBKeyframeEasingCubicOut
        || easingType == kCCBKeyframeEasingCubicInOut
        || easingType == kCCBKeyframeEasingElasticIn
        || easingType == kCCBKeyframeEasingElasticOut
        || easingType == kCCBKeyframeEasingElasticInOut)
    {
        [self writeFloat:easingOpt];
    }
    
    // Write value
    if ([type isEqualToString:@"Check"])
    {
        [self writeBool:[value boolValue]];
    }
    else if ([type isEqualToString:@"Byte"])
    {
        [self writeByte:[value intValue]];
    }
    else if ([type isEqualToString:@"Color3"])
    {
        int a = [[value objectAtIndex:0] intValue];
        int b = [[value objectAtIndex:1] intValue];
        int c = [[value objectAtIndex:2] intValue];
        [self writeByte:a];
        [self writeByte:b];
        [self writeByte:c];
    }
    else if ([type isEqualToString:@"Degrees"])
    {
        [self writeFloat:[value floatValue]];
    }
    else if ([type isEqualToString:@"ScaleLock"]
             || [type isEqualToString:@"Position"]
             || [type isEqualToString:@"FloatXY"])
    {
        float a = [[value objectAtIndex:0] floatValue];
        float b = [[value objectAtIndex:1] floatValue];
        [self writeFloat:a];
        [self writeFloat:b];
    }
    else if ([type isEqualToString:@"SpriteFrame"])
    {
        NSString* a = [value objectAtIndex:1];
        NSString* b = [value objectAtIndex:0];
        
        if ([b isEqualToString:@"Use regular file"]) b = @"";
        if ([a isEqualToString:@"Use regular file"]) a = @"";
        
        if ([self isSprite:b inGeneratedSpriteSheet:a])
        {
            a = [[b stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
        }
        
        [self writeCachedString:a isPath:YES];
        [self writeCachedString:b isPath:[a isEqualToString:@""]];
    }
}

- (void) writeNodeGraph:(NSDictionary*)node
{
    // Write class
    NSString* class = [node objectForKey:@"customClass"];
    if (jsControlled) class = @"";
    
    BOOL hasCustomClass = YES;
    if (!class || [class isEqualToString:@""])
    {
        class = [node objectForKey:@"baseClass"];
        hasCustomClass = NO;
    }
    [self writeCachedString:class isPath:NO];
    
    // Write controller
    if (jsControlled)
    {
        NSString* jsController = [node objectForKey:@"jsController"];
        if (!jsController) jsController = @"";
        [self writeCachedString:jsController isPath:NO];
    }
    
    // Write assignment type and name
    int memberVarAssignmentType = [[node objectForKey:@"memberVarAssignmentType"] intValue];
    [self writeInt:memberVarAssignmentType withSign:NO];
    if (memberVarAssignmentType)
    {
        [self writeCachedString:[node objectForKey:@"memberVarAssignmentName"] isPath:NO];
    }
    
    // Write animated properties
    NSDictionary* animatedProps = [node objectForKey:@"animatedProperties"];
    
    // Animated sequences count
    [self writeInt:(int)[animatedProps count] withSign:NO];
    
    
    for (NSString* seqIdStr in animatedProps)
    {
        // Write a sequence
        
        int seqId = [seqIdStr intValue];
        [self writeInt:seqId withSign:NO];
        
        NSDictionary* props = [animatedProps objectForKey:seqIdStr];
        
        // Animated properties count
        [self writeInt:(int)[props count] withSign:NO];
        
        for (NSString* propName in props)
        {
            NSMutableDictionary* prop = [props objectForKey:propName];
            
            // Write a sequence node property
            [self writeCachedString:propName isPath:NO];
            
            // Write property type
            int kfType = [[prop objectForKey:@"type"] intValue];
            NSString* propType = NULL;
            if (kfType == kCCBKeyframeTypeToggle) propType = @"Check";
            else if (kfType == kCCBKeyframeTypeByte) propType = @"Byte";
            else if (kfType == kCCBKeyframeTypeColor3) propType = @"Color3";
            else if (kfType == kCCBKeyframeTypeDegrees) propType = @"Degrees";
            else if (kfType == kCCBKeyframeTypeScaleLock) propType = @"ScaleLock";
            else if (kfType == kCCBKeyframeTypeSpriteFrame) propType = @"SpriteFrame";
            else if (kfType == kCCBKeyframeTypePosition) propType = @"Position";
            else if (kfType == kCCBKeyframeTypeFloatXY) propType = @"FloatXY";
            
            NSAssert(propType, @"Unknown animated property type");
            
            [self writeInt:[self propTypeIdForName:propType] withSign:NO];
            
            // Write number of keyframes
            NSArray* keyframes = [prop objectForKey:@"keyframes"];
            
            if (kfType == kCCBKeyframeTypeToggle && keyframes.count > 0)
            {
                BOOL visible = YES;
                NSDictionary* keyframeFirst = [keyframes objectAtIndex:0];
                if ([[keyframeFirst objectForKey:@"time"] floatValue] != 0)
                {
                    [self writeInt:(int)[keyframes count]+1 withSign:NO];
                    // Add a first keyframe
                    [self writeKeyframeValue:[NSNumber numberWithBool:NO] type:propType time:0 easingType:kCCBKeyframeEasingInstant easingOpt:0];
                }
                else
                {
                    [self writeInt:(int)[keyframes count] withSign:NO];
                }
                for (NSDictionary* keyframe in keyframes)
                {
                    float time = [[keyframe objectForKey:@"time"] floatValue];
                    [self writeKeyframeValue:[NSNumber numberWithBool:visible] type:propType time:time easingType:kCCBKeyframeEasingInstant easingOpt:0];
                    visible = !visible;
                }
                
            }
            else
            {
                [self writeInt:(int)[keyframes count] withSign:NO];
                
                for (NSDictionary* keyframe in keyframes)
                {
                    // Write a keyframe
                    id value = [keyframe objectForKey:@"value"];
                    float time = [[keyframe objectForKey:@"time"] floatValue];
                    NSDictionary* easing = [keyframe objectForKey:@"easing"];
                    int easingType = [[easing objectForKey:@"type"] intValue];
                    float easingOpt = [[easing objectForKey:@"opt"] floatValue];
                    
                    [self writeKeyframeValue:value type: propType time:time easingType: easingType easingOpt: easingOpt];
                }
            }
        }
    }
    
    // Write properties
    NSArray* props = [node objectForKey:@"properties"];
    NSArray* customProps = [node objectForKey:@"customProperties"];
    
    // Only write customProps if there is a custom class
    if (!hasCustomClass) customProps = [NSArray array];
    
    [self writeInt:(int)[props count] withSign:NO];
    [self writeInt:(int)[customProps count] withSign:NO];
    
    for (int i = 0; i < [props count]; i++)
    {
        NSDictionary* prop = [props objectAtIndex:i];
        
        id value = [prop objectForKey:@"value"];
        NSString* type = [prop objectForKey:@"type"];
        NSString* name = [prop objectForKey:@"name"];
        id baseValue = [prop objectForKey:@"baseValue"];
        
        if (baseValue)
        {
            // We need to transform the base value to a normal value (base values override normal values)
            if ([type isEqualToString:@"Position"])
            {
                value = [NSArray arrayWithObjects:
                         [baseValue objectAtIndex:0],
                         [baseValue objectAtIndex:1],
                         [value objectAtIndex:2],
                         nil];
            }
            else if ([type isEqualToString:@"ScaleLock"])
            {
                value = [NSArray arrayWithObjects:
                         [baseValue objectAtIndex:0],
                         [baseValue objectAtIndex:1],
                         [NSNumber numberWithBool:NO],
                         [value objectAtIndex:3],
                         nil];
            }
            else if ([type isEqualToString:@"SpriteFrame"])
            {
                NSString* a = [baseValue objectAtIndex:0];
                NSString* b = [baseValue objectAtIndex:1];
                if ([b isEqualToString:@"Use regular file"]) b = @"";
                
                if ([self isSprite:a inGeneratedSpriteSheet:b])
                {
                    b = [[a stringByDeletingLastPathComponent] stringByAppendingPathExtension:@"plist"];
                }
                
                value = [NSArray arrayWithObjects:b, a, nil];
            }
            else
            {
                // Value needs no transformation
                value = baseValue;
            }
        }
        
        [self writeProperty:value type:type name:name platform:[prop objectForKey:@"platform"]];
    }
    
    // Write custom properties
    for (NSDictionary* customProp in customProps)
    {
        int customType = [[customProp objectForKey:@"type"] intValue];
        NSString* customValue = [customProp objectForKey:@"value"];
        NSString* name = [customProp objectForKey:@"name"];
        
        NSString* type = NULL;
        id value = NULL;
        
        if (customType == kCCBCustomPropTypeInt)
        {
            type = @"Integer";
            value = [NSNumber numberWithInt:[customValue intValue]];
        }
        else if (customType == kCCBCustomPropTypeFloat)
        {
            type = @"Float";
            value = [NSNumber numberWithFloat:[customValue floatValue]];
        }
        else if (customType == kCCBCustomPropTypeBool)
        {
            type = @"Check";
            value = [NSNumber numberWithBool:[customValue boolValue]];
        }
        else if (customType == kCCBCustomPropTypeString)
        {
            type = @"String";
            value = customValue;
        }
        
        NSAssert(type, @"Failed to find custom type");
        
        [self writeProperty:value type:type name:name platform:kCCBXPlatformAll];
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
    jsControlled = [[doc objectForKey:@"jsControlled"] boolValue];
    
    [self cacheStringsForNode:nodeGraph];
    [self cacheStringsForSequences:doc];
    [self transformStringCache];
    
    [self writeHeader];
    [self writeStringCache];
    [self writeSequences:doc];
    [self writeNodeGraph:nodeGraph];
}

@end
