//
//  YLTabBarController.m
//  Duorey
//
//  Created by xdy on 14/11/28.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "YLTabBarController.h"

@interface YLTabBarController ()

@property (strong, nonatomic) UIView *shadeView;

@end

@implementation YLTabBarController

@synthesize shadeView = _shadeView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonItemTitleByEmpty];
    NSArray *itemArray = self.tabBar.items;
    UITabBarItem *explore = [itemArray objectAtIndex:0];
    explore.image = [UIImage imageNamed:@"tabExplore"];
    explore.selectedImage = [[UIImage imageNamed:@"tabExploreOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *activity = [itemArray objectAtIndex:1];
    activity.image = [UIImage imageNamed:@"tabActivity"];
    activity.selectedImage = [[UIImage imageNamed:@"tabActivityOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *playlist = [itemArray objectAtIndex:2];
    playlist.image = [UIImage imageNamed:@"tabPlaylist"];
    playlist.selectedImage = [[UIImage imageNamed:@"tabPlaylistOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *profile = [itemArray objectAtIndex:3];
    profile.image = [UIImage imageNamed:@"tabProfile"];
    profile.selectedImage = [[UIImage imageNamed:@"tabProfileOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
