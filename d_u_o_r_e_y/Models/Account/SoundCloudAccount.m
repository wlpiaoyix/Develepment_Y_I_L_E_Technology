//
//  SoundCloudAccount.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SoundCloudAccount.h"

@implementation SoundCloudAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"accessToken":@"access_token",
             @"scope":@"scope"
             };
}

@end
