//
//  AttributedLabel.h
//  AttributedStringTest
//
//  Created by sun huayu on 13-2-19.
//  Copyright (c) 2013年 sun huayu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface AttributedLabel : UILabel

/**
 *  设置某段字的颜色
 *
 *  @param color    颜色
 *  @param location 开始位置
 *  @param length   作用长度
 */
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length;

/**
 *  设置某段字的字体
 *
 *  @param font     字体
 *  @param location 开始位置
 *  @param length   作用长度
 */
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length;

/**
 *  设置某段字的风格
 *
 *  @param style    下划线style
 *  @param location 开始位置
 *  @param length   作用长度
 */
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length;

@end
