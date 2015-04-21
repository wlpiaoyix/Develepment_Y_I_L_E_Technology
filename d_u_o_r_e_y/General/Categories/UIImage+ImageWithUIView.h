//
//  UIImage+ImageWithUIView.h
//  InFollows
//
//  Created by xdy on 13-10-31.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (ImageWithUIView)

+ (UIImage *)imageWithUIView:(UIView *)view;
+ (UIImage *)imageWithCGRect:(CGRect)rect;
@end
