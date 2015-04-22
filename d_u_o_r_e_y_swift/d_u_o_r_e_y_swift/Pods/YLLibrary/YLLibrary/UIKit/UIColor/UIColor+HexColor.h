//
//  UIColor+HexColor.h
//  UIColorHexColor
//
//  Created by Matt Quiros on 2/8/14.
//  Copyright (c) 2014 Matt Quiros. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

/**
 *  根据16进制返回相应的颜色对象
 *
 *  @param hex 16进制
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorFromHex:(unsigned long)hex;

@end
