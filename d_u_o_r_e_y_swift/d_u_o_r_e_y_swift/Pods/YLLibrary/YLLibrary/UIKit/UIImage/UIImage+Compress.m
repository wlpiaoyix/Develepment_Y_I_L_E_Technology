//
//  UIImage+Compress.m
//  AuidoAndVideoDemo
//
//  Created by xdy on 13-11-15.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "UIImage+Compress.h"

@implementation UIImage (Compress)

#pragma -mark 根据指定的类型 返回resize的图片对象
- (UIImage *)imageToScaleSize:(CGSize)newSize withSizeType:(ImageResizingType)sizeType {
    CGFloat sourceImageScale = 1.0;
    if ([self respondsToSelector:@selector(scale)]) {
        sourceImageScale = self.scale;
    }
    
    CGFloat sourceWidth = self.size.width * sourceImageScale;
    CGFloat sourceHeight = self.size.height * sourceImageScale;
    
    if (sourceWidth <= newSize.width && sourceHeight <= newSize.height) {
        return self;
    }
    
    if (sourceWidth == 0 || sourceHeight == 0) {
        return self;
    }
    
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    
    BOOL isCrop = !(sizeType == ImageResizingScale);
    
    CGFloat sourceRatio = sourceWidth / sourceHeight;
    CGFloat targetRatio = targetWidth / targetHeight;
    
    BOOL scaleWidth = (sourceRatio <= targetRatio);
    scaleWidth = (isCrop) ? scaleWidth : !scaleWidth;
    
    CGFloat scaledWidth;
    CGFloat scaledHeight;
    if (scaleWidth) {
        scaledWidth = targetWidth;
        scaledHeight = round(targetWidth * (1.0 / sourceRatio));
    } else {
        scaledWidth = round(targetHeight * sourceRatio);
        scaledHeight = targetHeight;
    }
    
    CGFloat scaleFactor = scaledHeight / sourceHeight;
    
    CGRect sourceRect;
    CGRect targetRect;
    
    //如果有剪切  根据剪切的类型来重新计算
    if (isCrop) {
		targetRect = CGRectMake(0, 0, targetWidth, targetHeight);
		CGFloat targetX;
        CGFloat targetY;
        
        if (ImageResizingCropStart == sizeType)
        {
            if (scaleWidth) {// Crop top
                targetX = 0.0;
                targetY = 0.0;
            } else {// Crop left
                targetX = 0.0;
                targetY = round((scaledHeight - targetHeight) * 0.5);
            }
        } else if (ImageResizingCropCenter == sizeType) {
            targetX = round((scaledWidth - targetWidth) * 0.5);
            targetY = round((scaledHeight - targetHeight) * 0.5);
        } else {
            if (scaleWidth) { // Crop bottom
                targetX = round((scaledWidth - targetWidth) * 0.5);
                targetY = round(scaledHeight - targetHeight);
            } else {// Crop right
                targetX = round(scaledWidth - targetWidth);
                targetY = round((scaledHeight - targetHeight) * 0.5);
            }
        }
        
        sourceRect = CGRectMake(targetX / scaleFactor, targetY / scaleFactor,
								targetWidth / scaleFactor, targetHeight / scaleFactor);
	} else {
		sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
		targetRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
	}

    UIImage *targetImage = nil;
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(targetRect.size, NO, 0.f);
		sourceImg = CGImageCreateWithImageInRect(self.CGImage, sourceRect);
		targetImage = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation];
	} else {
		UIGraphicsBeginImageContext(targetRect.size);
		sourceImg = CGImageCreateWithImageInRect(self.CGImage, sourceRect);
		targetImage = [UIImage imageWithCGImage:sourceImg];
	}
	
	CGImageRelease(sourceImg);
	[targetImage drawInRect:targetRect];
	targetImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return targetImage;
}

#pragma -mark 根据新size resize图片
- (UIImage *)scaleToSize:(CGSize)newSize {
    CGFloat sourceWidth = self.size.width;
    CGFloat sourceHeight = self.size.height;
    
    if (sourceWidth <= newSize.width && sourceHeight <= newSize.height) {
        return self;
    }
    
    if (sourceWidth == 0 || sourceHeight == 0) {
        return self;
    }
    
    CGFloat widthFactor = newSize.width / sourceWidth;
    CGFloat heightFactor = newSize.height / sourceHeight;
    CGFloat scaleFactor = (widthFactor < heightFactor ? widthFactor : heightFactor);
    
    CGFloat scaledWidth = round(sourceWidth * scaleFactor);
    CGFloat scaledHeight = round(sourceHeight * scaleFactor);

    CGRect targetRect = CGRectZero;
    
    if (widthFactor > heightFactor) {
        targetRect.origin.y = (newSize.height - scaledHeight) * 0.5;
    } else if (widthFactor < heightFactor) {
        targetRect.origin.x = (newSize.width - scaledWidth) * 0.5;
    }
    targetRect.size.width = scaledWidth;
    targetRect.size.height = scaledHeight;
    
//    CGImageRef sourceImg = self.CGImage;
    UIImage *targetImage = nil;
    
    UIGraphicsBeginImageContext(targetRect.size);
    targetImage = [UIImage imageWithCGImage:self.CGImage];
    
//    CGImageRelease(sourceImg);

    [targetImage drawInRect:targetRect];
    targetImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return targetImage;
}

#pragma -mark 返回图片的NSData对象
- (NSData *)imageJPEGRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    return UIImageJPEGRepresentation(self, compressionQuality);
}

@end
