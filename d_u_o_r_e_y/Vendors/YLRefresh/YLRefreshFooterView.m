//
//  YLRefreshFooterView.m
//  MessageDisplayExample
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import "YLRefreshFooterView.h"
#import "PTTheme.h"

@interface YLRefreshFooterView ()

/**
 *  系统默认菊花控件
 */

@end

@implementation YLRefreshFooterView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.isLoadMoreRefreshed = YES;
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [self.superview removeObserver:self forKeyPath:@"contentSize" context:nil];

    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [newSuperview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

        // 设置宽度
//        self.yl_width = newSuperview.yl_width;
        // 设置位置
//        self.yl_x = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
//        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

- (void)startLoading {
    self.loadMoreButton.userInteractionEnabled = NO;
    [self.loadMoreButton setTitle:self.footerViewIsLoadingText forState:UIControlStateNormal];
    [self.activityIndicatorView startAnimating];
}

- (void)endLoading {
//    self.alpha = 0;
    self.loadMoreButton.userInteractionEnabled = NO;
    [self.loadMoreButton setTitle:self.footerViewLoadingEnededText forState:UIControlStateNormal];
    [self.activityIndicatorView stopAnimating];
}

- (void)configuraManualStateWithMessage:(NSString *)message {
    self.loadMoreButton.userInteractionEnabled = YES;
    [self.loadMoreButton setTitle:message forState:UIControlStateNormal];
}

- (void)configuraNothingMoreWithMessage:(NSString *)message {
    self.alpha = 0.0f;
    self.loadMoreButton.userInteractionEnabled = NO;
    [self.loadMoreButton setTitle:message forState:UIControlStateNormal];
}

- (void)setupCustomLoadMoreButton:(UIButton *)customLoadMoreButton {
    [customLoadMoreButton addTarget:self action:@selector(loadMoreButtonClciked:) forControlEvents:UIControlEventTouchUpInside];
    customLoadMoreButton.frame = self.loadMoreButton.frame;
    if (_loadMoreButton) {
        [_loadMoreButton removeFromSuperview];
        _loadMoreButton = nil;
    }
    _loadMoreButton = customLoadMoreButton;
    [self insertSubview:_loadMoreButton atIndex:0];
}


- (void)loadMoreButtonClciked:(UIButton *)sender {
    [self callBeginLoadMoreRefreshing];
}

#pragma mark - Property

- (UIButton *)loadMoreButton {
    if (!_loadMoreButton) {
//        _loadMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(self.bounds) - 20, CGRectGetHeight(self.bounds) - 10)];
        _loadMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.bounds) - 20, 50)];
        _loadMoreButton.userInteractionEnabled = NO;
//        [_loadMoreButton setTitle:self.footerViewLoadingEnededText forState:UIControlStateNormal];
//        [_loadMoreButton setTitle:@"Loading..." forState:UIControlStateNormal];
        _loadMoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        [_loadMoreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_loadMoreButton setBackgroundColor:[UIColor clearColor]];
        [_loadMoreButton addTarget:self action:@selector(loadMoreButtonClciked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loadMoreButton;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.bounds) / 3, CGRectGetHeight(self.bounds) / 4);
        _activityIndicatorView.color = [[PTThemeManager sharedTheme] navTintColor];
    }
    return _activityIndicatorView;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.loadMoreButton];
        [self addSubview:self.activityIndicatorView];
        [self setup];
    }
    return self;
}

- (void)dealloc {
    _loadMoreButton = nil;
    _activityIndicatorView = nil;
}

- (BOOL)isLoadMoreRefreshed {
    return YES;
}

- (CGFloat)preloadValue {
    return self.preloadDistance;
}

- (NSString *)AutoLoadMoreRefreshedMessage {
    return self.displayAutoLoadMoreRefreshedMessage;
}

- (void)callBeginLoadMoreRefreshing {
    if (self.loadMoreRefreshing)
        return;
    self.loadMoreRefreshing = YES;
    self.loadMoreRefreshedCount ++;
    self.refreshState = YLRefreshStateLoading;
    [self startLoading];
    
    if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
        msgSend(msgTarget(self.beginRefreshingTaget), self.beginRefreshingAction, self);
    }
}

- (void)endMoreOverWithMessage:(NSString *)message {
    [self endLoadMoreRefresing];
    self.noMoreDataForLoaded = YES;
    [self configuraNothingMoreWithMessage:message];
}

- (void)endLoadMoreRefresing {
    self.alpha = 0;
    if (self.isLoadMoreRefreshed) {
        self.loadMoreRefreshing = NO;
        self.refreshState = YLRefreshStateNormal;
        [self endLoading];
    }
}

- (void)handleLoadMoreError {
    [self endLoadMoreRefresing];
    [self configuraManualStateWithMessage:[self displayAutoLoadMoreRefreshedMessage]];
    self.loadMoreRefreshedCount = self.autoLoadMoreRefreshedCount;
}

// 触发上拉刷新动作
- (void)startLoadMoreRefreshing {
    self.alpha = 1.0f;
//    NSLog(@"%ld, %d", (long)self.loadMoreRefreshedCount, self.autoLoadMoreRefreshedCount);
    if (self.isLoadMoreRefreshed) {
        if (self.loadMoreRefreshedCount < self.autoLoadMoreRefreshedCount) {
            [self callBeginLoadMoreRefreshing];
        } else {
            [self configuraManualStateWithMessage:self.displayAutoLoadMoreRefreshedMessage];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        // 上提加载更多的逻辑方法
        if (self.isLoadMoreRefreshed) {
            int currentPostion = contentOffset.y;
            
            if (currentPostion > 0) {
                
                CGRect bounds = self.scrollView.bounds;//边界
                
                CGSize size = self.scrollView.contentSize;//滚动视图内容区域size
                
                UIEdgeInsets inset = self.scrollView.contentInset;//视图周围额外的滚动视图区域
                
                float y = currentPostion + bounds.size.height + inset.bottom;
                
                //判断是否滚动到底部
//                if(((y - size.height) + self.preloadValue) > kXHLoadMoreViewHeight && self.isLoadMoreRefreshed && !self.noMoreDataForLoaded) {
                    if(((y - size.height) + self.preloadValue) > kXHLoadMoreViewHeight && self.refreshState != YLRefreshStateLoading && self.isLoadMoreRefreshed && !self.loadMoreRefreshing && !self.noMoreDataForLoaded) {
                    [self startLoadMoreRefreshing];
                }
            }
        }
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize contentSize = [[change valueForKey:NSKeyValueChangeNewKey] CGSizeValue];
        if (self.isLoadMoreRefreshed && !self.noMoreDataForLoaded && !self.pullDownRefreshing) {
            CGRect loadMoreViewFrame = self.frame;
            loadMoreViewFrame.origin.y = contentSize.height;
            self.frame = loadMoreViewFrame;
            [self setScrollViewContentInsetForLoadMore];
        } else {
            CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);
            CGFloat thubs = scrollViewHeight - self.scrollView.contentInset.top;
            if (contentSize.height >= thubs) {
                CGRect loadMoreViewFrame = self.frame;
                loadMoreViewFrame.origin.y = contentSize.height;
                self.frame = loadMoreViewFrame;
            }
        }
    }
}

- (void)configuraObserverWithScrollView:(UIScrollView *)scrollView {
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setup {
    self.loadMoreRefreshedCount = 0;
    self.originalBottomInset = self.scrollView.contentInset.bottom;
    
    self.refreshState = YLRefreshStateNormal;
    
//    [self configuraObserverWithScrollView:self.scrollView];

    [self.scrollView addSubview:self];
    
//    self.hasStatusLabelShowed = YES;
//    
//    self.circleColor = [UIColor colorWithRed:173 / 255.0 green:53 / 255.0 blue:60 / 255.0 alpha:1];
//    
//    self.circleLineWidth = 1.0;
}

- (CGFloat)getAdaptorHeight {
    return self.scrollView.contentInset.top;
}

- (void)setScrollViewContentInsetForLoadMore {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = kXHLoadMoreViewHeight + self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         if (finished && self.refreshState == YLRefreshStateStopped) {
                             if (!self.scrollView.isDragging)
                                 self.refreshState = YLRefreshStateNormal;
                             
//                             if (self.refreshCircleContainerView.circleView) {
//                                 [self.refreshCircleContainerView.circleView.layer removeAllAnimations];
//                             }
                         }
                     }];
}

@end
