//
//  UserFollowViewController.h
//  Duorey
//
//  Created by xdy on 14/11/24.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTEnum.h"

@interface UserFollowViewController : UITableViewController

@property (assign, nonatomic) UserFollowType followType;
@property (strong, nonatomic) NSNumber *userId;

@end
