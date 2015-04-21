//
//  UIView+Extension.m
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import "UIView+YLExtension.h"

@implementation UIView (YLExtension)
- (void)setYl_x:(CGFloat)yl_x
{
    CGRect frame = self.frame;
    frame.origin.x = yl_x;
    self.frame = frame;
}

- (CGFloat)yl_x
{
    return self.frame.origin.x;
}

- (void)setYl_y:(CGFloat)yl_y
{
    CGRect frame = self.frame;
    frame.origin.y = yl_y;
    self.frame = frame;
}

- (CGFloat)yl_y
{
    return self.frame.origin.y;
}

- (void)setYl_width:(CGFloat)yl_width
{
    CGRect frame = self.frame;
    frame.size.width = yl_width;
    self.frame = frame;
}

- (CGFloat)yl_width
{
    return self.frame.size.width;
}

- (void)setYl_height:(CGFloat)yl_height
{
    CGRect frame = self.frame;
    frame.size.height = yl_height;
    self.frame = frame;
}

- (CGFloat)yl_height
{
    return self.frame.size.height;
}

- (void)setYl_size:(CGSize)yl_size
{
    CGRect frame = self.frame;
    frame.size = yl_size;
    self.frame = frame;
}

- (CGSize)yl_size
{
    return self.frame.size;
}

- (void)setYl_origin:(CGPoint)yl_origin
{
    CGRect frame = self.frame;
    frame.origin = yl_origin;
    self.frame = frame;
}

- (CGPoint)yl_origin
{
    return self.frame.origin;
}
@end
