//
//  NSString+Path.h
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)
/**
 *  返回NSSearchPathDirectory的路径L
 *
 *  @param searchPathDirectory NSSearchPathDirectory
 *
 *  @return 路径
 */
+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)searchPathDirectory;

/**
 *  返回NSDocumentDirectory的路径
 *
 *  @return NSDocumentDirectory的路径
 */
+ (NSURL *)documentURL;

/**
 *  返回NSApplicationSupportDirectory的路径
 *
 *  @return NSApplicationSupportDirectory的路径
 */
+ (NSString *)applcationSuppportDirectory;

/**
 *  返回NSDocumentDirectory的路径
 *
 *  @return NSDocumentDirectory的路径
 */
+ (NSString *)documentDirectory;

/**
 *  返回NSCachesDirectory的路径
 *
 *  @return NSCachesDirectory的路径
 */
+ (NSString *)cacheDirectory;

/**
 *  返回Resources的路径
 *
 *  @return Resources的路径
 */
+ (NSString *)resourcesDirectory;

/**
 *  返回Resources/Images的路径
 *
 *  @return Images路径
 */
+ (NSString *)imageDirectory;

/**
 *  返回Resources/data的路径
 *
 *  @return data路径
 */
+ (NSString *)dataDirectory;

@end
