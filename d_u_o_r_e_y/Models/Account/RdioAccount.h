//
//  RidoAccount.h
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Mantle.h>

@interface RdioAccount : MTLModel<MTLJSONSerializing>

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *accessTokenSecret;
@property (copy, nonatomic) NSString *fullAccessToken;
@property (copy, nonatomic) NSString *rdioKey;
@property (copy, nonatomic) NSString *rdioSecret;
@end
