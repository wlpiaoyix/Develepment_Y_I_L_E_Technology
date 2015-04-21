//
//  UIScrollView+Extension.m
//  YLRefresh
//
//  Created by yong he on 14-12-01.
//  Copyright (c) 2014年. All rights reserved.
//

#import "UIScrollView+YLExtension.h"

@implementation UIScrollView (YLExtension)
- (void)setYl_contentInsetTop:(CGFloat)yl_contentInsetTop
{
    UIEdgeInsets inset = self.contentInset;
    inset.top = yl_contentInsetTop;
    self.contentInset = inset;
}

- (CGFloat)yl_contentInsetTop
{
    return self.contentInset.top;
}

- (void)setYl_contentInsetBottom:(CGFloat)yl_contentInsetBottom
{
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = yl_contentInsetBottom;
    self.contentInset = inset;
}

- (CGFloat)yl_contentInsetBottom
{
    return self.contentInset.bottom;
}

- (void)setYl_contentInsetLeft:(CGFloat)yl_contentInsetLeft
{
    UIEdgeInsets inset = self.contentInset;
    inset.left = yl_contentInsetLeft;
    self.contentInset = inset;
}

- (CGFloat)yl_contentInsetLeft
{
    return self.contentInset.left;
}

- (void)setYl_contentInsetRight:(CGFloat)yl_contentInsetRight
{
    UIEdgeInsets inset = self.contentInset;
    inset.right = yl_contentInsetRight;
    self.contentInset = inset;
}

- (CGFloat)yl_contentInsetRight
{
    return self.contentInset.right;
}

- (void)setYl_contentOffsetX:(CGFloat)yl_contentOffsetX
{
    CGPoint offset = self.contentOffset;
    offset.x = yl_contentOffsetX;
    self.contentOffset = offset;
}

- (CGFloat)yl_contentOffsetX
{
    return self.contentOffset.x;
}

- (void)setYl_contentOffsetY:(CGFloat)yl_contentOffsetY
{
    CGPoint offset = self.contentOffset;
    offset.y = yl_contentOffsetY;
    self.contentOffset = offset;
}

- (CGFloat)yl_contentOffsetY
{
    return self.contentOffset.y;
}

- (void)setYl_contentSizeWidth:(CGFloat)yl_contentSizeWidth
{
    CGSize size = self.contentSize;
    size.width = yl_contentSizeWidth;
    self.contentSize = size;
}

- (CGFloat)yl_contentSizeWidth
{
    return self.contentSize.width;
}

- (void)setYl_contentSizeHeight:(CGFloat)yl_contentSizeHeight
{
    CGSize size = self.contentSize;
    size.height = yl_contentSizeHeight;
    self.contentSize = size;
}

- (CGFloat)yl_contentSizeHeight
{
    return self.contentSize.height;
}
@end
