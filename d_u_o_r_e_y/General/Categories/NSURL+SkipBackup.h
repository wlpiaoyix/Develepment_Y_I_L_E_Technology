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

+ (BOOL)addSkipBackupAttributeToItemURL:(NSURL *)fileURL;

- (BOOL)addSkipBackupAttribute;

@end