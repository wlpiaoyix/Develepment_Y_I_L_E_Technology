//
//  UIActionSheet+Attachment.h
//  PhonTunes
//
//  Created by xdy on 14-2-24.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString * const kNewActionSheetAttachmentKey = @"kNewActionSheetAttachmentKey";

@interface UIActionSheet (Attachment)

@property (nonatomic, strong) id userInfo;

@end
