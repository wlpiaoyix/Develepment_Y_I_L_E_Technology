//
//  NSString+Hash.h
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

/**
 *  返回md5加密的字符串
 *
 *  @return md5加密后的字符串
 */
- (NSString *)md5;

/**
 *  返回sha1加密的字符串
 *
 *  @return sha1加密后的字符串
 */
- (NSString *)sha1;


- (NSString *)hmacSha1:(NSString *)key;

@end
