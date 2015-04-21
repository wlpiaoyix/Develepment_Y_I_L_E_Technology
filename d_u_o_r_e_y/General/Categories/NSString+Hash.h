//
//  NSString+Hash.h
//  Inlikes
//
//  Created by xdy on 13-9-30.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)hmacSha1:(NSString *)key;
@end
