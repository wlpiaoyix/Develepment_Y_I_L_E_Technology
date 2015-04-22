//
//  NSString+Path.m
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)

+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)searchPathDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:searchPathDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)documentURL {
    return [self URLForDirectory:NSDocumentDirectory];
}

+ (NSString *)applcationSuppportDirectory {
    static NSString * applicationSupportDirectory;
    if (!applicationSupportDirectory) {
        applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    }

    return applicationSupportDirectory;
}

+ (NSString *)documentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cacheDirectory {
    static NSString *cacheDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    });

    return cacheDirectory;
}

+ (NSString *)resourcesDirectory {
    static NSString * resourceDirectory;
    if (!resourceDirectory) {
        resourceDirectory = [[self cacheDirectory] stringByAppendingPathComponent:@"Resources"];
        NSFileManager * fm = [NSFileManager defaultManager];
        BOOL isDir = YES;
        if (![fm fileExistsAtPath:resourceDirectory isDirectory:&isDir] && isDir) {
            [fm createDirectoryAtPath:resourceDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return resourceDirectory;
}

+ (NSString *)imageDirectory {
    static NSString * imageDirectory;
    if (!imageDirectory) {
        imageDirectory = [[self resourcesDirectory] stringByAppendingPathComponent:@"Images"];
        NSFileManager * fm = [NSFileManager defaultManager];
        BOOL isDir = YES;
        if (![fm fileExistsAtPath:imageDirectory isDirectory:&isDir] && isDir) {
            [fm createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }

    return imageDirectory;
}

+ (NSString *)dataDirectory{
	static NSString * lyricsDir;
    if (!lyricsDir) {
        lyricsDir = [[self resourcesDirectory] stringByAppendingPathComponent:@"data"];
        NSFileManager * fm = [NSFileManager defaultManager];
        BOOL isDir = YES;
        if (![fm fileExistsAtPath:lyricsDir isDirectory:&isDir] && isDir) {
            [fm createDirectoryAtPath:lyricsDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }

    return lyricsDir;
}
@end
