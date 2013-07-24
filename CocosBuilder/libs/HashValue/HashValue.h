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
#import <CommonCrypto/CommonDigest.h>

#define HASH_VALUE_STORAGE_SIZE 48

typedef struct
{
	char value[CC_SHA256_DIGEST_LENGTH];
} HashValueShaHash;

typedef struct
{
	char value[CC_MD5_DIGEST_LENGTH];
} HashValueMD5Hash;

typedef enum
{
	HASH_VALUE_MD5_TYPE,
	HASH_VALUE_SHA_TYPE
} HashValueType;

@interface HashValue : NSObject <NSCoding, NSCopying>
{
	unsigned char value[HASH_VALUE_STORAGE_SIZE];
	HashValueType type;
}

- (id)initWithBuffer:(const void *)buffer hashValueType:(HashValueType)aType;
- (id)initHashValueMD5HashWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (HashValue *)md5HashWithData:(NSData *)data;
+ (HashValue *)md5HashWithString:(NSString*) string;
- (id)initSha256HashWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (HashValue *)sha256HashWithData:(NSData *)data;

- (const void *)value;
- (HashValueType)type;

@end
