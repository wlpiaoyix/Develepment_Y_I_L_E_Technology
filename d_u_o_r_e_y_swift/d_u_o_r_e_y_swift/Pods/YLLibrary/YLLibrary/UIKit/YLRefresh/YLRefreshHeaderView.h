//
//  YLRefreshHeaderView.h
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//  下拉刷新

#import "YLRefreshBaseView.h"
#import "YLRefreshConst.h"

@interface YLRefreshHeaderView : YLRefreshBaseView

@property (nonatomic, copy) NSString *dateKey;
+ (instancetype)header;
@property (nonatomic, readwrite) CGFloat originalTopInset;

@end