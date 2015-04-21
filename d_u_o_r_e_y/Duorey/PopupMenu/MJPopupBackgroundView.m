//
//  MJPopupBackgroundView.m
//  watched
//
//  Created by Martin Juhasz on 18.06.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import "MJPopupBackgroundView.h"

@implementation MJPopupBackgroundView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    size_t locationsCount = 2;
//    CGFloat locations[2] = {0.0f, 1.0f};
//    CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
//    CGColorSpaceRelease(colorSpace);
//
//    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 88/2);
//    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
//    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
//
//    CGPoint startPoint = self.bounds.origin;
//    CGPoint endPoint = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
//    CGContextDrawLinearGradient(context, gradient, endPoint, startPoint, kCGGradientDrawsBeforeStartLocation);
//    CGGradientRelease(gradient);

    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
    CGContextFillRect(context, self.bounds);
    CGContextStrokePath(context);
}


@end
