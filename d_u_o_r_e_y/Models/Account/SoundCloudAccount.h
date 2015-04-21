//
//  SoundCloudAccount.h
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Mantle.h>

@interface SoundCloudAccount : MTLModel<MTLJSONSerializing>

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *scope;
@property (copy, nonatomic) NSString *soundCloudKey;
@property (copy, nonatomic) NSString *soundCloudSecret;

@end
