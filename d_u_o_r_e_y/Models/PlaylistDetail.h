//
//  PlaylistDetail.h
//  Duorey
//
//  Created by lixu on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"
#import "Music.h"
#import "UserAccount.h"

@interface PlaylistDetail : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) Music *music;
@property (strong, nonatomic) UserAccount *userAccount;

@end
