//
//  LoginPageContentViewController.h
//  Duorey
//
//  Created by xdy on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTEnum.h"
#import "UserAccount.h"

@class ThirdpartyLoginViewController;

@protocol ThirdpartyLoginViewControllerDelegate <NSObject>

@optional
- (void)thirdpartyLoginViewController:(ThirdpartyLoginViewController *)controller didLoginSuccess:(UserAccount *)user;

@end

@interface ThirdpartyLoginViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) id<ThirdpartyLoginViewControllerDelegate> delegate;
@end
