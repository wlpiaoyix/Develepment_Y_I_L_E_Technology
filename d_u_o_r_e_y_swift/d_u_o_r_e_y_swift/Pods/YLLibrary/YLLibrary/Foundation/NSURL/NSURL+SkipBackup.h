//
// NSURL+SkipBackup
// PhonTunes
//
//
//  Created by xdy on 13-12-12.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSURL (SkipBackup)

/**
 *  添加是否过滤指定文件地址备份
 *
 *  @param fileURL 文件地址
 *
 *  @return 是否
 */
+ (BOOL)addSkipBackupAttributeToItemURL:(NSURL *)fileURL;

/**
 *  添加是否过滤当前文件地址的备份
 *
 *  @return 是否
 */
- (BOOL)addSkipBackupAttribute;

@end