//
//  UIImage+Compress.h
//  AuidoAndVideoDemo
//
//  Created by xdy on 13-11-15.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageResizingType){
    ImageResizingCropStart,
    ImageResizingCropCenter,
    ImageResizingCropEnd,
    ImageResizingScale
};

@interface UIImage (Compress)

- (UIImage *)imageToScaleSize:(CGSize)newSize withSizeType:(ImageResizingType)sizeType;
- (UIImage *)scaleToSize:(CGSize)newSize;
- (NSData *)imageJPEGRepresentationWithCompressionQuality:(CGFloat)compressionQuality;
@end
