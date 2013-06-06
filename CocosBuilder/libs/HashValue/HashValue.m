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

#import "HashValue.h"

@implementation HashValue

- (id)initWithBuffer:(const void *)buffer hashValueType:(HashValueType)aType
{
	self = [super init];
	if (self != nil)
	{
		if (aType == HASH_VALUE_MD5_TYPE)
		{
			memcpy(value, buffer, sizeof(HashValueMD5Hash));
		}
		else if (aType == HASH_VALUE_SHA_TYPE)
		{
			memcpy(value, buffer, sizeof(HashValueShaHash));
		}
		type = aType;
	}
	return self;
}

- (id)initHashValueMD5HashWithBytes:(const void *)bytes length:(NSUInteger)length
{
	self = [super init];
	if (self != nil)
	{
		CC_MD5(bytes, length, value);
		type = HASH_VALUE_MD5_TYPE;
	}
	return self;
}

+ (HashValue *)md5HashWithData:(NSData *)data
{
	return [[[HashValue alloc]
		initHashValueMD5HashWithBytes:[data bytes]
		length:[data length]]
	autorelease];
}

+ (HashValue *)md5HashWithString:(NSString*) string
{
    return [[[HashValue alloc] initHashValueMD5HashWithBytes:[string UTF8String] length:strlen([string UTF8String])] autorelease];
}

- (id)initSha256HashWithBytes:(const void *)bytes length:(NSUInteger)length
{
	self = [super init];
	if (self != nil)
	{
		CC_SHA256(bytes, length, value);
		type = HASH_VALUE_SHA_TYPE;
	}
	return self;
}

+ (HashValue *)sha256HashWithData:(NSData *)data
{
	return [[[HashValue alloc]
		initSha256HashWithBytes:[data bytes]
		length:[data length]]
	autorelease];
}

- (NSString *)description
{
	NSInteger byteLength = 0;
	if (type == HASH_VALUE_MD5_TYPE)
	{
		byteLength = sizeof(HashValueMD5Hash);
	}
	else if (type == HASH_VALUE_SHA_TYPE)
	{
		byteLength = sizeof(HashValueShaHash);
	}

	NSMutableString *stringValue =
		[NSMutableString stringWithCapacity:byteLength * 2];
	NSInteger i;
	for (i = 0; i < byteLength; i++)
	{
		[stringValue appendFormat:@"%02x", value[i]];
	}
	
	return stringValue;
}

- (NSUInteger)hash
{
	return *((NSUInteger *)value);
}

- (const void *)value
{
	return value;
}

- (HashValueType)type
{
	return type;
}

- (BOOL)isEqual:(id)other
{
	if ([other isKindOfClass:[HashValue class]] &&
		((HashValue *)other)->type == type &&
		memcmp(((HashValue *)other)->value, value, HASH_VALUE_STORAGE_SIZE) == 0)
	{
		return YES;
	}
	
	return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWithBuffer:value hashValueType:type];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
	self = [super init];
	if (self != nil)
	{
		NSData *valueData = [aCoder decodeObjectForKey:@"value"];
		memcpy(value, [valueData bytes], [valueData length]);
		[valueData self];
		
		type = [aCoder decodeIntForKey:@"type"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder
		encodeObject:[NSData dataWithBytes:value length:HASH_VALUE_STORAGE_SIZE]
		forKey:@"value"];
	[encoder encodeInt:type forKey:@"type"];
}

@end
