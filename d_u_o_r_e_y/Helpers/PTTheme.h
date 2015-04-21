//
//  PTTheme.h
//  PhonTunes
//
//  Created by CoreXDY on 14-3-9.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PTTheme <NSObject>

#pragma mark - new

//@required

#pragma mark - color

//基本颜色
- (UIColor *)whiteColor;
- (UIColor *)blackColor;
- (UIColor *)grayColor;
- (UIColor *)greenColor;
- (UIColor *)redColor;

//nav
- (UIColor *)navBarTintColor;
- (UIColor *)navTintColor;

//tabbar
- (UIColor *)tabBarTintColor;
- (UIColor *)tabTintColor;

//progress
- (UIColor *)progressTintColor;
- (UIColor *)progressTrackTintColor;

//toolbar
- (UIColor *)toolBarTintColor;

//slider
- (UIColor *)sliderTintColor;

- (UIColor *)shadowColor;
- (UIColor *)backgroundColor;

- (UIColor *)badgeColor;
- (UIColor *)accentTintColor;

- (UIColor *)switchThumbColor;
- (UIColor *)switchOnColor;
- (UIColor *)switchTintColor;

- (CGSize)shadowOffset;

- (NSDictionary *)navigationBarTitleTextAttributes;

- (UIImage *)topShadow;
- (UIImage *)bottomShadow;

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;

- (UIImage *)searchBackground;
- (UIImage *)searchFieldImage;
- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state;
- (UIImage *)searchScopeButtonDivider;

- (UIImage *)sliderMinTrack;
- (UIImage *)sliderMaxTrack;
- (UIImage *)sliderThumbImageForState:(UIControlState)state;

- (UIImage *)greenButtonBackgroundForState:(UIControlState)state;
- (UIImage *)redButtonBackgroundForState:(UIControlState)state;

- (UIImage *)loginButtonBackgroundWithImage:(NSString *)imageName;

- (UIImage *)tableViewBackground;
- (UIImage *)tabBarBackground;
- (UIImage *)tabBarSelectedIndicatorImage;
@end


@interface PTThemeManager : NSObject

+ (id <PTTheme>)sharedTheme;

+ (void)customizeAppAppearance;
+ (UIButton *)customPlayButtonAddTarget:(id)target action:(SEL)action;
+ (void)customizeTableView:(UITableView *)tableView;
+ (void)customizeWhiteHeadView:(UIView *)view;
+ (void)customizeGrayHeadView:(UIView *)view;

@end