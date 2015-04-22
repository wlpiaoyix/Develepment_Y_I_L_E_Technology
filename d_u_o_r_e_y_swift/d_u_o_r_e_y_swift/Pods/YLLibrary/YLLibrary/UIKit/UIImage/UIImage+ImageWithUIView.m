//
//  UIImage+ImageWithUIView.m
//  InFollows
//
//  Created by xdy on 13-10-31.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)

#pragma mark - takeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view {
    CGSize screenShotSize = view.bounds.size;
    UIImage *img;
    UIGraphicsBeginImageContext(screenShotSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view drawLayer:view.layer inContext:ctx];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)imageWithCGRect:(CGRect)rect {
    CGSize imageSize = rect.size;
    UIImage *targetImage = nil;
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 245.0/255.0, 245.0/255.0, 245.0/255.0, 1.0);
    CGContextFillRect(context, rect);
    CGContextStrokePath(context);
    targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return targetImage;
}

@end
