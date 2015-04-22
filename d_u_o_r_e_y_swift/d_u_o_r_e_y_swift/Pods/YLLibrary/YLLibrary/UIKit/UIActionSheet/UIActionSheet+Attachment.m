//
//  UIActionSheet+Attachment.m
//  PhonTunes
//
//  Created by xdy on 14-2-24.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "UIActionSheet+Attachment.h"

@implementation UIActionSheet (Attachment)

@dynamic userInfo;

- (void)setUserInfo:(id)userInfo {
    objc_setAssociatedObject(self,
                             (__bridge const void *)(KASNewActionSheetAttachmentKey),
                             userInfo,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userInfo {
    return objc_getAssociatedObject(self, (__bridge const void *)(KASNewActionSheetAttachmentKey));
}

@end
