//
//  UIScrollView+Extension.h
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (YLExtension)
@property (assign, nonatomic) CGFloat yl_contentInsetTop;
@property (assign, nonatomic) CGFloat yl_contentInsetBottom;
@property (assign, nonatomic) CGFloat yl_contentInsetLeft;
@property (assign, nonatomic) CGFloat yl_contentInsetRight;

@property (assign, nonatomic) CGFloat yl_contentOffsetX;
@property (assign, nonatomic) CGFloat yl_contentOffsetY;

@property (assign, nonatomic) CGFloat yl_contentSizeWidth;
@property (assign, nonatomic) CGFloat yl_contentSizeHeight;
@end
