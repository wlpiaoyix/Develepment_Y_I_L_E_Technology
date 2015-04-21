//
//  RidoAccount.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "RdioAccount.h"

@implementation RdioAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"accessToken":@"accessToken",
             @"accessTokenSecret":@"accessTokenSecret",
             @"fullAccessToken":@"fullAccessToken"
             };
}

@end
