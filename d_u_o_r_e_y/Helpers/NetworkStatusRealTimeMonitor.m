//
//  NetworkStatusRealTimeMonitor.m
//  Duorey
//
//  Created by xdy on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "NetworkStatusRealTimeMonitor.h"
#import <AFNetworkReachabilityManager.h>
#import "PTUtilities.h"
#import <UALogger.h>
#import "AppDelegate.h"

#define ViewHeight [[UIScreen mainScreen] bounds].size.height
#define ViewWidth [[UIScreen mainScreen] bounds].size.width

@interface NetworkStatusRealTimeMonitor(){
    AFNetworkReachabilityManager *_afReachabilityManager;
    UIView *_noReachabilityView;
}

@end

@implementation NetworkStatusRealTimeMonitor

+ (instancetype)sharedNetworkMonitor{
    static NetworkStatusRealTimeMonitor *_sharedNetworkMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNetworkMonitor = [[NetworkStatusRealTimeMonitor alloc] init];
    });
    
    return _sharedNetworkMonitor;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _afReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    }
    
    return self;
}

- (void)dealloc{
    removeNotificationObserver(AFNetworkingReachabilityDidChangeNotification, self, nil);
}

- (void)startMonitoring{
    [_afReachabilityManager startMonitoring];
    [_afReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        postNotification(AFNetworkingReachabilityDidChangeNotification, nil, @{ AFNetworkingReachabilityNotificationStatusItem: @(status) });
    }];
}
- (void)stopMonitoring{
    [_afReachabilityManager stopMonitoring];
    removeNotificationObserver(AFNetworkingReachabilityDidChangeNotification, self, nil);
}

- (void)removeReachabilityStatusNotification{
   removeNotificationObserver(AFNetworkingReachabilityDidChangeNotification, self, nil);
}

- (void)addReachabilityStatusNotification{
    addNotificationObserver(AFNetworkingReachabilityDidChangeNotification, self, @selector(reachabilityDidChangeNotification:), nil);
}

#pragma mark - no network view

- (void)removeNoNetworkView{
    [_noReachabilityView removeFromSuperview];
}

- (void)setupNoNetworkView{
    if (!_noReachabilityView) {
        _noReachabilityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
        _noReachabilityView.userInteractionEnabled = YES;
        _noReachabilityView.backgroundColor = [UIColor blackColor];
        _noReachabilityView.alpha = 0.5f;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, ViewWidth, 45)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:0.847 green:0.901 blue:0.433 alpha:1.000];
        label.numberOfLines = 3;
        label.text = PTNSLocalizedString(@"NetworkNotAvailableMsgKey", nil);
        [_noReachabilityView addSubview:label];
    }
    [self removeNoNetworkView];
    [((AppDelegate *)[UIApplication sharedApplication].delegate).window addSubview:_noReachabilityView];
}

#pragma mark - network change

- (void)reachabilityDidChangeNotification:(NSNotification *)notification{
    if (notification) {
        AFNetworkReachabilityStatus reachabilityStatus = [[notification.userInfo valueForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
        
        switch (reachabilityStatus) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
            {
                //无网
                UALog(@"无网络了。。%@",[_afReachabilityManager localizedNetworkReachabilityStatusString]);
                [self setupNoNetworkView];
                
            }
                break;
                
            default:
            {
                //有网
                UALog(@"有网络了。。%@",[_afReachabilityManager localizedNetworkReachabilityStatusString]);
                [self removeNoNetworkView];
            }
                
                break;
        }
    }
    
}

@end
