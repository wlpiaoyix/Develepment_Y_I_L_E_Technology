//
//  YLRefreshConst.h
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#ifdef DEBUG
#define YLLog(...) NSLog(__VA_ARGS__)
#else
#define YLLog(...)
#endif

// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

#define YLColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
// 文字颜色
#define YLRefreshLabelTextColor YLColor(150, 150, 150)

// 图片路径
#define YLRefreshSrcName(file) [@"YLRefresh.bundle" stringByAppendingPathComponent:file]

#ifndef YLRefreshLocalizedStrings
#define YLRefreshLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"YLRefresh", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"YLRefresh.bundle"]], nil)
#endif

UIKIT_EXTERN const CGFloat YLRefreshViewHeight;
UIKIT_EXTERN const CGFloat YLRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat YLRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const YLRefreshHeaderTimeKey;

UIKIT_EXTERN NSString *const YLRefreshContentOffset;
UIKIT_EXTERN NSString *const YLRefreshContentSize;