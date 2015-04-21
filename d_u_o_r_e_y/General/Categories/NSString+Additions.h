//
//  NSString+Additions.h
//  PhonTunes
//
//  Created by xdy on 14-2-18.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL)isEmpty;
- (NSString *)trim;
- (NSString *)firstCharacterUppercase;
- (NSString *)firstCharacterLowercase;
- (long)videoDuration;
+ (long)videoDurationFromNSString:(NSString *)dstr;
- (NSString *)videoDurationString;
@end
