//
//  NSData+AES.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Encryption)

/**
 *  加密
 *
 *  @param key 加密的key
 *
 *  @return 加密之后的数据
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/**
 *  解密
 *
 *  @param key 解密的key
 *
 *  @return 解密之后的数据
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
