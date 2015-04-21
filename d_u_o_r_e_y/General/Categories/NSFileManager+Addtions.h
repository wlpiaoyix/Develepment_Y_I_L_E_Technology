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

- (unsigned long long)systemTotalSize;
- (unsigned long long)systemFreeSize;
- (unsigned long long)sizeAtPath:(NSString *)path;

@end
