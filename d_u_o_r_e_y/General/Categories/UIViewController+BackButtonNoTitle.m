//
//  UIViewController+BackButtonNoTitle.m
//  Duorey
//
//  Created by xdy on 15/1/21.
//  Copyright (c) 2015年 www.yileapp.com. All rights reserved.
//

#import "UIViewController+BackButtonNoTitle.h"

@implementation UIViewController (BackButtonNoTitle)

- (void)setBackButtonItemTitleByEmpty{
    UIBarButtonItem *backNoTitleButtonItem = [[UIBarButtonItem alloc] init];
    backNoTitleButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backNoTitleButtonItem;
}

@end
