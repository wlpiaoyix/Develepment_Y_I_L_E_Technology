//
//  Spotify.h
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Mantle.h>

@interface SpotifyAccount : MTLModel<MTLJSONSerializing>

@property(copy, nonatomic) NSString *tokenType;
@property(copy, nonatomic) NSString *accessToken;
@property(copy, nonatomic) NSString *expiresIn;
@property(copy, nonatomic) NSString *refreshToken;
@property(copy, nonatomic) NSString *spotifyKey;
@property(copy, nonatomic) NSString *spotifySecret;
@property(strong, nonatomic) NSDate *expiresDate;
@property(copy, nonatomic) NSString *userName;
@property(copy, nonatomic) NSString *product;

@end
