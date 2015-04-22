
#import "NYXImagesHelper.h"

typedef enum
{
	NYXCropModeTopLeft,
	NYXCropModeTopCenter,
	NYXCropModeTopRight,
	NYXCropModeBottomLeft,
	NYXCropModeBottomCenter,
	NYXCropModeBottomRight,
	NYXCropModeLeftCenter,
	NYXCropModeRightCenter,
	NYXCropModeCenter
} NYXCropMode;

typedef enum
{
	NYXResizeModeScaleToFill,
	NYXResizeModeAspectFit,
	NYXResizeModeAspectFill
} NYXResizeMode;


@interface UIImage (NYX_Resizing)

/**
 *  根据尺寸和模式裁剪图片
 *
 *  @param newSize  新尺寸
 *  @param cropMode 模式
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)cropToSize:(CGSize)newSize usingMode:(NYXCropMode)cropMode;

/**
 *  根据NYXCropModeTopLeft和尺寸裁剪图片
 *
 *  @param newSize 新尺寸
 *
 *  @return 裁剪后的图片
 */
- (UIImage *)cropToSize:(CGSize)newSize;

/**
 *  按比例缩放图片
 *
 *  @param scaleFactor 比例
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleByFactor:(float)scaleFactor;

/**
 *  按比例和模式缩放图片
 *
 *  @param newSize    新尺寸
 *  @param resizeMode 模式
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleToSize:(CGSize)newSize usingMode:(NYXResizeMode)resizeMode;

/**
 *  按NYXResizeModeScaleToFill和尺寸缩放图片
 *
 *  @param newSize 新尺寸
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleToSize:(CGSize)newSize;

/**
 *  缩放图片以适应新尺寸
 *
 *  @param newSize 新尺寸
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleToFillSize:(CGSize)newSize;

/**
 *  按aspect fit和尺寸缩放图片
 *
 *  @param newSize 新尺寸
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleToFitSize:(CGSize)newSize;

/**
 *  aspect fill和尺寸缩放图片
 *
 *  @param newSize 新尺寸
 *
 *  @return 缩放后的图片
 */
- (UIImage *)scaleToCoverSize:(CGSize)newSize;

@end
