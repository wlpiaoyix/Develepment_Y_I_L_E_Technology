//
//  UITabBarController+Addtions.m
//  PhonTunes
//
//  Created by xdy on 14-1-18.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "UITabBarController+Addtions.h"

@implementation UITabBarController (Addtions)

- (id)viewControllerAtIndex:(NSInteger)index {
    id fetchViewController = [[self childViewControllers] objectAtIndex:index];
    
    if ([fetchViewController isKindOfClass:[UINavigationController class]]) {
        fetchViewController = [fetchViewController topViewController];
    }

    return fetchViewController;
}

- (UITabBarItem *)tabBarItemAtIndex:(NSInteger)index {
    return [[[self tabBar] items] objectAtIndex:index];
}

@end
