//
//  UIImage+ImageWithUIView.h
//  InFollows
//
//  Created by xdy on 13-10-31.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (ImageWithUIView)

/**
 *  根据提供的view 返回一个image对象
 *
 *  @param view view对象  根据此对象生成图片
 *
 *  @return image对象
 */
+ (UIImage *)imageWithUIView:(UIView *)view;

/**
 *  根据提供的rect 返回一个image对象
 *
 *  @param rect 图片的大小
 *
 *  @return image对象
 */
+ (UIImage *)imageWithCGRect:(CGRect)rect;

@end
