//
//  YLRefreshHeaderView.m
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//  下拉刷新

#import "YLRefreshHeaderView.h"
#import "UIView+YLExtension.h"
#import "UIScrollView+YLExtension.h"

@interface YLRefreshHeaderView()
// 最后的更新时间
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, weak) UILabel *lastUpdateTimeLabel;
@end

@implementation YLRefreshHeaderView
#pragma mark - 控件初始化
/**
 *  时间标签
 */
- (UILabel *)lastUpdateTimeLabel
{
    if (!_lastUpdateTimeLabel) {
        // 1.创建控件
        UILabel *lastUpdateTimeLabel = [[UILabel alloc] init];
        lastUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdateTimeLabel.font = [UIFont boldSystemFontOfSize:12];
        lastUpdateTimeLabel.textColor = YLRefreshLabelTextColor;
        lastUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lastUpdateTimeLabel = lastUpdateTimeLabel];
        
        // 2.加载时间
        if(self.dateKey){
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:self.dateKey];
        } else {
            self.lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:YLRefreshHeaderTimeKey];
        }
    }
    return _lastUpdateTimeLabel;
}

+ (instancetype)header
{
    return [[YLRefreshHeaderView alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = YLRefreshLocalizedStrings(@"Pull to refresh");
        self.releaseToRefreshText = YLRefreshLocalizedStrings(@"Release to refresh");
        self.refreshingText = YLRefreshLocalizedStrings(@"Refreshing...");
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusX = 0;
    CGFloat statusY = 0;
    CGFloat statusHeight = self.yl_height * 0.5;
    CGFloat statusWidth = self.yl_width;
    // 1.状态标签
    self.statusLabel.frame = CGRectMake(statusX, statusY+10, statusWidth, statusHeight);
    
    // 2.时间标签
    CGFloat lastUpdateY = statusHeight;
    CGFloat lastUpdateX = 0;
    CGFloat lastUpdateHeight = statusHeight;
    CGFloat lastUpdateWidth = statusWidth;
    self.lastUpdateTimeLabel.frame = CGRectMake(lastUpdateX, lastUpdateY, lastUpdateWidth, lastUpdateHeight);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 设置自己的位置和尺寸
    self.yl_y = - self.yl_height;
}

#pragma mark - 状态相关
#pragma mark 设置最后的更新时间
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;
    
    // 1.归档
    if(self.dateKey){
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:self.dateKey];
    }   else{
        [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:YLRefreshHeaderTimeKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2.更新时间
    [self updateTimeLabel];
}

#pragma mark 更新时间字符串
- (void)updateTimeLabel
{
    if (!self.lastUpdateTime) return;
    
    // 1.获得年月日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:_lastUpdateTime];
    NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    
    // 2.格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([cmp1 day] == [cmp2 day]) { // 今天
        formatter.dateFormat = @"HH:mm";
    } else if ([cmp1 year] == [cmp2 year]) { // 今年
        formatter.dateFormat = @"MM-dd HH:mm";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    NSString *time = [formatter stringFromDate:self.lastUpdateTime];
    
    // 3.显示日期
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:YLRefreshLocalizedStrings(@"Last Updated：%@"), time];
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat pullDownOffset = (MIN(ABS(self.scrollView.contentOffset.y + self.scrollView.contentInset.top), 60) - 20);

    if (self.scrollView.contentOffset.y <= -(self.originalTopInset - 20)) {
        CGFloat timeOffset = pullDownOffset / 36.0;
        self.arrowImage.activityIndicatorView.timeOffset = timeOffset;
    }
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;

    // 如果正在刷新，直接返回
    if (self.state == YLHeaderRefreshStateRefreshing) return;

    if ([YLRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.yl_contentOffsetY;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.yl_height;
        
        if (self.state == YLHeaderRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = YLHeaderRefreshStatePulling;
        } else if (self.state == YLHeaderRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = YLHeaderRefreshStateNormal;
        }
    } else if (self.state == YLHeaderRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = YLHeaderRefreshStateRefreshing;
    }
}

#pragma mark 设置状态
- (void)setState:(YLHeaderRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    YLHeaderRefreshState oldState = self.state;
    
    // 3.调用父类方法
    [super setState:state];
    
    // 4.根据状态执行不同的操作
	switch (state) {
		case YLHeaderRefreshStateNormal: // 下拉可以刷新
        {
            // 刷新完毕
            if (YLHeaderRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                // 保存刷新时间
                self.lastUpdateTime = [NSDate date];
                
                [UIView animateWithDuration:YLRefreshSlowAnimationDuration animations:^{
//#warning 这句代码修复了，top值不断累加的bug
                    if (self.scrollViewOriginalInset.top == 0) {
                        self.scrollView.yl_contentInsetTop = 0;
                    } else if (self.scrollViewOriginalInset.top == self.scrollView.yl_contentInsetTop) {
                        self.scrollView.yl_contentInsetTop -= self.yl_height;
                    } else {
                        self.scrollView.yl_contentInsetTop = self.scrollViewOriginalInset.top;
                    }
                }];
            } else {
                // 执行动画
                [UIView animateWithDuration:YLRefreshFastAnimationDuration animations:^{
//                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
			break;
        }
            
		case YLHeaderRefreshStatePulling: // 松开可立即刷新
        {
            [self.arrowImage.activityIndicatorView beginRefreshing];
            // 执行动画
            [UIView animateWithDuration:YLRefreshFastAnimationDuration animations:^{
//                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
//                self.arrowImage.transform = CGAffineTransformIdentity;

            }];
			break;
        }
            
		case YLHeaderRefreshStateRefreshing: // 正在刷新中
        {
            // 执行动画
            [UIView animateWithDuration:YLRefreshFastAnimationDuration animations:^{
                // 1.增加滚动区域
                CGFloat top = self.scrollViewOriginalInset.top + self.yl_height;
                self.scrollView.yl_contentInsetTop = top;
                
                // 2.设置滚动位置
                self.scrollView.yl_contentOffsetY = - top;
            }];
			break;
        }
            
        default:
            break;
	}
}
@end