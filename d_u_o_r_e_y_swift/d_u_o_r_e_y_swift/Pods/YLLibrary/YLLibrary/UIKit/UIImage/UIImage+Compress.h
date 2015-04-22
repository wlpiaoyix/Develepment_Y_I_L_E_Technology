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

/**
 *  根据提供的resize类型 调整图片的size
 *
 *  @param newSize  新的size
 *  @param sizeType 调整的类型
 *
 *  @return 调整之后的图片
 */
- (UIImage *)imageToScaleSize:(CGSize)newSize withSizeType:(ImageResizingType)sizeType;

/**
 *  调整图片的size
 *
 *  @param newSize 新size
 *
 *  @return 返回调整之后的image
 */
- (UIImage *)scaleToSize:(CGSize)newSize;

/**
 *  根据提供的一个压缩质量参数  返回image的NSData对象
 *
 *  @param compressionQuality 压缩质量
 *
 *  @return NSData对象
 */
- (NSData *)imageJPEGRepresentationWithCompressionQuality:(CGFloat)compressionQuality;

@end
