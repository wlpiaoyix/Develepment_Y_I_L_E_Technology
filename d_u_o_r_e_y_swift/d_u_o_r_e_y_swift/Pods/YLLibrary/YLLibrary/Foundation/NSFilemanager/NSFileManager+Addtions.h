//
//  NSFileManager+Addtions.h
//  PhonTunes
//
//
//  Created by xdy on 13-12-12.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Addtions)

+ (unsigned long long)systemTotalSize;
+ (unsigned long long)systemFreeSize;
+ (unsigned long long)sizeAtPath:(NSString *)path;

/**
 *  返回系统文件的大小
 *
 *  @return 大小值
 */
- (unsigned long long)systemTotalSize;

/**
 *  返回系统文件剩余空间的大小
 *
 *  @return 大小值
 */
- (unsigned long long)systemFreeSize;

/**
 *  返回指定path的文件大小
 *
 *  @param path 路径
 *
 *  @return 大小值
 */
- (unsigned long long)sizeAtPath:(NSString *)path;

@end
