//
//  SelfUserProfile.h
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle.h>
#import "UserAccount.h"
#import "Music.h"
#import "MTLModel+DNullableScalar.h"

@interface SelfUserProfile : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) UserAccount *userAccount;
@property (strong, nonatomic) NSArray *recentArray;
@property (strong, nonatomic) NSArray *recentWeekArray;
@end
