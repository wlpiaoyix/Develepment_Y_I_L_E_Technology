//
//  Spotify.m
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "SpotifyAccount.h"

@implementation SpotifyAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"tokenType":@"token_type",
             @"accessToken":@"access_token",
             @"expiresIn":@"expires_in",
             @"refreshToken":@"refresh_token"
             };
}

@end
