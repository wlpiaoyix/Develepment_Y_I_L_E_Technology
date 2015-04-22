//
//  UIScrollView+YLRefresh.h
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLRefreshHeaderView.h"
#import "YLRefreshFooterView.h"

@interface UIScrollView (YLRefresh)

@property (weak, nonatomic) YLRefreshHeaderView *header;
@property (weak, nonatomic) YLRefreshFooterView *footer;
#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
//- (void)addHeaderWithCallback:(void (^)())callback;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 *  @param dateKey 刷新时间保存的key值
 */
//- (void)addHeaderWithCallback:(void (^)())callback dateKey:(NSString*)dateKey;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action;

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 *  @param dateKey 刷新时间保存的key值
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action dateKey:(NSString*)dateKey;

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader;

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing;

//@property (weak, nonatomic) id clickLoadMoreTarget;
//@property (assign, nonatomic) SEL clickLoadMoreAction;
/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing;

- (void)endMoreOverWithMessage:(NSString *)message;
- (void)endLoadMoreRefreshing;
/**
 *  下拉刷新头部控件的可见性
 */
@property (nonatomic, assign, getter = isHeaderHidden) BOOL headerHidden;

/**
 *  是否正在下拉刷新
 */
@property (nonatomic, assign, readonly, getter = isHeaderRefreshing) BOOL headerRefreshing;

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
//- (void)addFooterWithCallback:(void (^)())callback;

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action;

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter;

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing;
//@property (nonatomic, readwrite) CGFloat originalTopInset;

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
//- (void)footerEndRefreshing;

/**
 *  上拉刷新头部控件的可见性
 */
@property (nonatomic, assign, getter = isFooterHidden) BOOL footerHidden;

/**
 *  是否正在上拉刷新
 */
@property (nonatomic, assign, readonly, getter = isFooterRefreshing) BOOL footerRefreshing;

/**
 *  设置尾部控件的文字
 */
//@property (copy, nonatomic) NSString *footerPullToRefreshText; // 默认:@"上拉可以加载更多数据"
//@property (copy, nonatomic) NSString *footerReleaseToRefreshText; // 默认:@"松开立即加载更多数据"
//@property (copy, nonatomic) NSString *footerRefreshingText; // 默认:@"YL哥正在帮你加载数据..."

/**
 *  设置头部控件的文字
 */
@property (copy, nonatomic) NSString *headerPullToRefreshText; // 默认:@"下拉可以刷新"
@property (copy, nonatomic) NSString *headerReleaseToRefreshText; // 默认:@"松开立即刷新"
@property (copy, nonatomic) NSString *headerRefreshingText; // 默认:@"YL哥正在帮你刷新..."
@end
