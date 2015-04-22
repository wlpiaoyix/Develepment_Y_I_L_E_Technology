//
//  YLRefreshActivityIndicatorContainerView.h
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YLActivityCircleIndicatorView.h"

#import "YLRefreshControlHeader.h"

@interface YLRefreshActivityIndicatorContainerView : UIView

/**
 *  iOS7自定义菊花转圈控件
 */
@property (nonatomic, strong) YLActivityCircleIndicatorView *activityIndicatorView;

/**
 *  标识下拉刷新是UIScrollView的子view，还是UIScrollView父view的子view， 默认是scrollView的子View，为XHRefreshViewLayerTypeOnScrollViews
 */
@property (nonatomic, assign) XHRefreshViewLayerType refreshViewLayerType;

@end
