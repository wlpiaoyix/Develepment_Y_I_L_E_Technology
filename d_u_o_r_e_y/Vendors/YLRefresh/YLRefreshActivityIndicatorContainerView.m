//
//  YLRefreshActivityIndicatorContainerView.m
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import "YLRefreshActivityIndicatorContainerView.h"

@interface YLRefreshActivityIndicatorContainerView ()

@end

@implementation YLRefreshActivityIndicatorContainerView

#pragma mark - Propertys

- (void)setRefreshViewLayerType:(XHRefreshViewLayerType)refreshViewLayerType {
    _refreshViewLayerType = refreshViewLayerType;
    
    CGRect activityIndicatorViewFrame;
    switch (refreshViewLayerType) {
        case XHRefreshViewLayerTypeOnSuperView:
            activityIndicatorViewFrame = CGRectMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) * 0.4, 0, 0);
            break;
        case XHRefreshViewLayerTypeOnScrollViews:
            activityIndicatorViewFrame = CGRectMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) * 0.6, 0, 0);
            break;
        default:
            break;
    }
    self.activityIndicatorView.frame = activityIndicatorViewFrame;
}

- (YLActivityCircleIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[YLActivityCircleIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) * 0.6, 0, 0)];
        _activityIndicatorView.refreshViewLayerType = XHRefreshViewLayerTypeOnScrollViews;
        
    }
    return _activityIndicatorView;
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self addSubview:self.activityIndicatorView];
    }
}

- (void)dealloc {
    _activityIndicatorView = nil;
}

@end
