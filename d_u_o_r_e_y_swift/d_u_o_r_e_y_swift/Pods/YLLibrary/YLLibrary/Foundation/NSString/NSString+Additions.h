//
//  NSString+Additions.h
//  PhonTunes
//
//  Created by xdy on 14-2-18.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

/**
 *  判断字符串是否为空
 *
 *  @return 是否为空
 */
- (BOOL)isEmpty;

/**
 *  删除字符串的空格和换行
 *
 *  @return 字符串
 */
- (NSString *)trim;

/**
 *  返回首字符大写的字符串
 *
 *  @return 首字符大写的字符串
 */
- (NSString *)firstCharacterUppercase;

/**
 *  返回首字符小写的字符串
 *
 *  @return 首字符小写的字符串
 */
- (NSString *)firstCharacterLowercase;

/**
 *  返回当前字符串的播放长度
 *
 *  @return 长度数值
 */
- (long)videoDuration;

/**
 *  根据字符串返回以秒为单位的数值
 *
 *  @param dstr 字符串
 *
 *  @return 数值
 */
+ (long)videoDurationFromNSString:(NSString *)dstr;

/**
 *  返回一个以H:M:S格式的字符串
 *
 *  @return 字符串
 */
- (NSString *)videoDurationString;

@end
