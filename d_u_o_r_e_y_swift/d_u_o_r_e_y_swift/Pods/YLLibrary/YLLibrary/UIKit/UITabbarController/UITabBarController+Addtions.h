//
//  UITabBarController+Addtions.h
//  PhonTunes
//
//  Created by xdy on 14-1-18.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Addtions)
/**
 *  根据index返回controller
 *
 *  @param index tabbar的index
 *
 *  @return controller对象
 */
- (id)viewControllerAtIndex:(NSInteger)index;

/**
 *  获取指定index的tabbaritem
 *
 *  @param index tabbar的index
 *
 *  @return tabbaritem对象
 */
- (UITabBarItem *)tabBarItemAtIndex:(NSInteger)index;

@end
