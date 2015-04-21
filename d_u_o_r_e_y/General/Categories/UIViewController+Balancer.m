//
//  UIViewController+Balancer.m
//  Test
//
//  Created by ice on 14/11/26.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import "UIViewController+Balancer.h"
#import "BalancerView.h"

@implementation UIViewController (Balancer)

- (void)setUpBalancerView {
    BalancerView *balancerView = [BalancerView instanceView];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:balancerView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentPlayer:)];
    [balancerView addGestureRecognizer:tap];
}

- (void)presentPlayer:(id)sender {
    UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"playerNav"];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
