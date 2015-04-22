//
//  NSString+MD5Encrypt.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

@interface NSString (MD5)

/**
 *  MD5加密
 *
 *  @return 返回MD5后的string
 */
- (NSString *)md5Encrypt;

@end
