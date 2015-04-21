//
//  NetworkStatusRealTimeMonitor.h
//  Duorey
//
//  Created by xdy on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkStatusRealTimeMonitor : NSObject

+ (instancetype)sharedNetworkMonitor;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)removeReachabilityStatusNotification;
- (void)addReachabilityStatusNotification;
@end
