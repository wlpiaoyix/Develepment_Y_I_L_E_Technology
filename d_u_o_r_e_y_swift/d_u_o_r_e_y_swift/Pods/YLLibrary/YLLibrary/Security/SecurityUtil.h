//
//  SecurityUtil.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject 

#pragma mark - base64

/**
 *  用base64编码
 *
 *  @param input 需要编码的字符串
 *
 *  @return 编码之后的string
 */
+ (NSString *)encodeBase64String:(NSString *)input;

/**
 *  解码base64 string
 *
 *  @param input 需要解码的string
 *
 *  @return 解码后的string
 */
+ (NSString *)decodeBase64String:(NSString *)input;

/**
 *  用base64编码
 *
 *  @param data 需要编码的数据
 *
 *  @return 编码后的string
 */
+ (NSString *)encodeBase64Data:(NSData *)data;

/**
 *  解码base64
 *
 *  @param data 需要解码的data
 *
 *  @return 解码后的string
 */
+ (NSString *)decodeBase64Data:(NSData *)data;

#pragma mark - AES加密

/**
 *  将string转成带密码的data
 *
 *  @param string 需要加密的string
 *
 *  @return 加密之后的数据
 */
+ (NSData *)encryptAESData:(NSString *)string;

/**
 *  将带密码的data转成string
 *
 *  @param data 需要转换的data
 *
 *  @return 转换之后的string
 */
+ (NSString *)decryptAESData:(NSData *)data;

#pragma mark - MD5加密

/**
 *	对string进行md5加密
 *
 *	@param 	string 	未加密的字符串
 *
 *	@return	md5加密后的字符串
 */
+ (NSString *)encryptMD5String:(NSString *)string;

@end
