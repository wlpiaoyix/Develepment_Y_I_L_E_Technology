//
//  NSFileManager+Addtions.m
//  PhonTunes
//
//
//  Created by xdy on 13-12-12.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "NSFileManager+Addtions.h"

@implementation NSFileManager (Addtions)

+ (unsigned long long)systemTotalSize {
    return [[self defaultManager] systemTotalSize];
}

+ (unsigned long long)systemFreeSize {
    return [[self defaultManager] systemFreeSize];
}

+ (unsigned long long)sizeAtPath:(NSString *)path {
    return [[self defaultManager] sizeAtPath:path];
}

- (unsigned long long)systemTotalSize {
    NSDictionary * systemAttributes = [self attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [systemAttributes[NSFileSystemSize] unsignedLongLongValue];
}

- (unsigned long long)systemFreeSize {
    NSDictionary * systemAttributes = [self attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [systemAttributes[NSFileSystemFreeSize] unsignedLongLongValue];
}

- (unsigned long long)sizeAtPath:(NSString *)path {
    path = path ?: NSHomeDirectory();
    BOOL isDir;
    // 如果是目录就直接返回大小
    if ([self fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
        NSDictionary * fileAttributes = [self attributesOfItemAtPath:path error:nil];
        return [fileAttributes fileSize];
    }
    // 如果是目录就遍历整个目录比累加文件大小
    NSDirectoryEnumerator * directoryEnumerator = [self enumeratorAtPath:path];
    NSString * file = [directoryEnumerator nextObject];
    unsigned long long fileSize = 0;
    while (file) {
        NSString * fullPath = [path stringByAppendingPathComponent:file];
        if ([self fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir) {
            NSDictionary * fileAttributes = [self attributesOfItemAtPath:fullPath error:nil];
            fileSize += [fileAttributes fileSize];
        }
        file = [directoryEnumerator nextObject];
    }
    
    return fileSize;
}

@end
