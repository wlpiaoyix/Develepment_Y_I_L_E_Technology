//
// NSURL+SkipBackup
// PhonTunes
//
//
//  Created by xdy on 13-12-12.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//


#import "NSURL+SkipBackup.h"
#import <sys/xattr.h>


@implementation NSURL (SkipBackup)

+ (BOOL)addSkipBackupAttributeToItemURL:(NSURL *)fileURL {
    return [fileURL addSkipBackupAttribute];
}

- (BOOL)addSkipBackupAttribute {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [self path]]);
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_1) {
        NSNumber *hasSkipped;
        if (![self getResourceValue:&hasSkipped forKey:NSURLIsExcludedFromBackupKey error:nil] || [hasSkipped boolValue] == NO) {
            return [self setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
        }
    }
    else {
        const char *filePath = [self.path fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue;
        getxattr(filePath, attrName, &attrValue, sizeof attrValue, 0, 0);
        if (attrValue != 1) {
            attrValue = 1;
            int result = setxattr(filePath, attrName, &attrValue, sizeof attrValue, 0, 0);
            return result == 0;
        }
    }

    return YES;
}

@end