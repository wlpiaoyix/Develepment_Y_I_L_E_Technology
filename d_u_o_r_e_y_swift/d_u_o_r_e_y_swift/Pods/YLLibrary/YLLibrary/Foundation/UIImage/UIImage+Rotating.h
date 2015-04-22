
#import "NYXImagesHelper.h"


@interface UIImage (NYX_Rotating)

/**
 *  根据radian旋转图片
 *
 *  @param radians radians
 *
 *  @return 旋转后的图片
 */
- (UIImage *)rotateInRadians:(float)radians;

/**
 *  根据角度旋转图片
 *
 *  @param degrees 角度
 *
 *  @return 旋转后的图片
 */
- (UIImage *)rotateInDegrees:(float)degrees;

/**
 *  根据radians旋转图片像素
 *
 *  @param radians radians
 *
 *  @return 旋转后的图片
 */
- (UIImage *)rotateImagePixelsInRadians:(float)radians;

/**
 *  根据角度旋转图片像素
 *
 *  @param degrees 角度
 *
 *  @return 旋转后的图片
 */
- (UIImage *)rotateImagePixelsInDegrees:(float)degrees;

/**
 *  返回垂直翻转后的图片
 *
 *  @return 图片
 */
- (UIImage *)verticalFlip;

/**
 *  返回水平翻转后的图片
 *
 *  @return 图片
 */
- (UIImage *)horizontalFlip;

@end
