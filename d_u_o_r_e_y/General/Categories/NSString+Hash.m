//
//  NSString+Hash.m
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "NSString+Hash.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Hash)

- (NSString *)md5 {
    const char *cString = [self UTF8String];
    unsigned char results[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, strlen(cString), results);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", results[i]];
    }
    
    return ret;
}

- (NSString *)sha1 {
    const char *cString = [self UTF8String];
    unsigned char results[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cString, strlen(cString), results);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", results[i]];
    }
    
    return ret;
}

- (NSString *)hmacSha1:(NSString *)key {
    const char *cString = [self UTF8String];
    const char *kString = [key UTF8String];
    unsigned char results[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, kString, strlen(kString), cString, strlen(cString), results);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", results[i]];
    }
    
    return ret;
}

@end
