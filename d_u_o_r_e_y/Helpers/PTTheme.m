//
//  PTTheme.m
//  PhonTunes
//
//  Created by CoreXDY on 14-3-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "PTTheme.h"
#import "PTLightgreenTheme.h"
#import <SVProgressHUD.h>

@implementation PTThemeManager

+ (id <PTTheme>)sharedTheme{
    static id <PTTheme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTheme = [[PTLightgreenTheme alloc] init];
    });
    
    return sharedTheme;
}

+ (void)customizeAppAppearance{
    id <PTTheme> theme = [self sharedTheme];

    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.7f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    //导航条
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
//    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:[theme navigationBarTitleTextAttributes]];
    [navigationBarAppearance setTintColor:[theme navTintColor]];
//    [navigationBarAppearance setBarTintColor:[theme navBarTintColor]];
    [navigationBarAppearance setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
    [backBarButtonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

    //Tabbar
    UITabBar *tabBarAppearance = [UITabBar appearance];
//    [tabBarAppearance setBarTintColor:[theme tabBarTintColor]];
    [tabBarAppearance setTintColor:[theme tabTintColor]];
//    [tabBarAppearance setSelectionIndicatorImage:[theme tabBarSelectedIndicatorImage]];
//
//    //Toolbar
//    UIToolbar *toolbarAppearance = [UIToolbar appearance];
////    [toolbarAppearance setBackgroundImage:[theme toolbarBackgroundForBarMetrics:UIBarMetricsDefault] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
//    [toolbarAppearance setTintColor:[theme toolBarTintColor]];

    //搜索框
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    [searchBarAppearance setTintColor:[theme navTintColor]];
//    [searchBarAppearance setBackgroundImage:[theme searchBackground]];
//    [searchBarAppearance setSearchFieldBackgroundImage:[theme searchFieldImage] forState:UIControlStateNormal];
//    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconSearch state:UIControlStateNormal] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconClear state:UIControlStateNormal] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
//    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconClear state:UIControlStateHighlighted] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];

    //进度条
//    UIProgressView *progressAppearance = [UIProgressView appearance];
//    [progressAppearance setTrackTintColor:[theme progressTrackTintColor]];
//
//    //滑块
    UISlider *sliderAppearance = [UISlider appearance];
    [sliderAppearance setTintColor:[theme sliderTintColor]];
    [sliderAppearance setThumbImage:[theme sliderThumbImageForState:UIControlStateNormal] forState:UIControlStateNormal];
//
//    UIAlertView *alertView = [UIAlertView appearance];
//    [alertView setTintColor:[theme greenColor]];
}

+ (UIButton *)customPlayButtonAddTarget:(id)target action:(SEL)action{
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:[UIImage imageNamed:@"navPlay"] forState:UIControlStateNormal];
//    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    button.frame = CGRectMake(0, 0, 44, 44);
//    return button;
    return nil;
}

+ (void)customizeTableView:(UITableView *)tableView{
    id <PTTheme> theme = [self sharedTheme];
    UIImage *backgroundImage = [theme tableViewBackground];
    UIColor *backgroundColor = [theme backgroundColor];
    if (backgroundImage) {
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        [tableView setBackgroundView:background];
    } else if (backgroundColor) {
        [tableView setBackgroundView:nil];
        [tableView setBackgroundColor:backgroundColor];
    }
}

+ (void)customizeWhiteHeadView:(UIView *)view{
    view.backgroundColor = [UIColor whiteColor];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, CGRectGetHeight(view.frame)-0.5, view.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1].CGColor;
    [view.layer addSublayer:bottomBorder];
}

+ (void)customizeGrayHeadView:(UIView *)view{
    view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0f];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, CGRectGetHeight(view.frame)-1, view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1].CGColor;
    [view.layer addSublayer:bottomBorder];
}

@end
