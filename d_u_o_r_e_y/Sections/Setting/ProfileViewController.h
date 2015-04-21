//
//  ProfileViewController.h
//  Duorey
//
//  Created by xdy on 14/11/11.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"

@interface ProfileViewController : UITableViewController

@property (strong, nonatomic) UserAccount *currentUser;

@end
