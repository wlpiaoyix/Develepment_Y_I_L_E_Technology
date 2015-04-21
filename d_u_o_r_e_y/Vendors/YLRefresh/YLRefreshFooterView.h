//
//  YLRefreshFooterView.h
//  MessageDisplayExample
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLRefreshConst.h"

typedef NS_ENUM(NSInteger, YLRefreshState) {
    YLRefreshStatePulling   = 0,
    YLRefreshStateNormal    = 1,
    YLRefreshStateLoading   = 2,
    YLRefreshStateStopped   = 3,
};
#define kXHLoadMoreViewHeight 100

@interface YLRefreshFooterView : UIView

@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (copy, nonatomic) NSString *pullToRefreshText;
@property (copy, nonatomic) NSString *releaseToRefreshText;
@property (copy, nonatomic) NSString *refreshingText;
/**
 *  开始进入刷新状态的监听方法
 */

@property (weak, nonatomic) id clickLoadMoreTarget;
@property (assign, nonatomic) SEL clickLoadMoreAction;
@property (weak, nonatomic) id beginRefreshingTaget;
@property (assign, nonatomic) SEL beginRefreshingAction;
@property (assign, nonatomic) CGFloat preloadDistance;
@property (nonatomic, assign) YLRefreshState refreshState;
@property (nonatomic, assign) BOOL pullDownRefreshing;
@property (nonatomic, assign) BOOL loadMoreRefreshing;

@property (nonatomic, assign) BOOL noMoreDataForLoaded;
/**
 *  加载更多的按钮
 */
@property (nonatomic, strong) UIButton *loadMoreButton;
//@property (nonatomic, assign) UIButton *customLoadMoreButton;


@property (nonatomic, strong) UIView *customRefreshView;

@property (nonatomic, assign) BOOL isPullDownRefreshed;
@property (nonatomic, assign) BOOL isLoadMoreRefreshed;
@property (nonatomic, assign) CGFloat refreshTotalPixels;
@property (nonatomic, assign) int autoLoadMoreRefreshedCount;
// recoder
//@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic, readwrite) CGFloat originalBottomInset;

// controll the loading and auto loading
@property (nonatomic, assign) NSInteger loadMoreRefreshedCount;

// preload more distanse
@property (nonatomic, assign) CGFloat preloadValue;
@property (nonatomic, assign) NSString *displayAutoLoadMoreRefreshedMessage;

@property (nonatomic, assign) NSString *footerViewIsLoadingText;
@property (nonatomic, assign) NSString *footerViewLoadingEnededText;

- (void)endLoadMoreRefresing;

/**
 *  当外部需要自定义加载更多的按钮时，需要通过该方法进行覆盖原本的按钮
 *
 *  @param customLoadMoreButton 目标自定义加载更多按钮
 */
- (void)setupCustomLoadMoreButton:(UIButton *)customLoadMoreButton;

/**
 *  开始加载
 */
- (void)startLoading;

/**
 *  结束加载
 */
//- (void)endLoading;

/**
 *  设置手动加载更多的UI
 */
- (void)configuraManualStateWithMessage:(NSString *)message;

/**
 *  当外部加载更多数据的时候，发现没有数据了，可以进行设置一些提示字眼
 *
 *  @param message 被显示的目标文本
 */
- (void)configuraNothingMoreWithMessage:(NSString *)message;

@end
