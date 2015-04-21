//
//  ProfileEditTableViewController.h
//  Duorey
//
//  Created by xdy on 14/11/20.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"

typedef enum {
    CropRectSquare = 0,
    CropRectRectangle
} CropRectType;

@class ProfileEditTableViewController;

@protocol ProfileEditTableViewControllerDelegate <NSObject>

- (void)didProfileUpdate:(ProfileEditTableViewController *)controller;

@end

@interface ProfileEditTableViewController : UITableViewController

@property (nonatomic, strong) UserAccount *currentAccount;
@property (assign, nonatomic) CGFloat imageHeight;
@property (nonatomic, assign) CropRectType cropRectType;

@property (weak, nonatomic) id<ProfileEditTableViewControllerDelegate> delegate;
@end
