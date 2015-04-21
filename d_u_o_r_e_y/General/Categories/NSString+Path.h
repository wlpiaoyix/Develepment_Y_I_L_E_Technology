//
//  NSString+Path.h
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Path)

+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)searchPathDirectory;
+ (NSURL *)documentURL;

+ (NSString *)applcationSuppportDirectory;
+ (NSString *)documentDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)resourcesDirectory;
+ (NSString *)imageDirectory;
+ (NSString *)dataDirectory;
@end
