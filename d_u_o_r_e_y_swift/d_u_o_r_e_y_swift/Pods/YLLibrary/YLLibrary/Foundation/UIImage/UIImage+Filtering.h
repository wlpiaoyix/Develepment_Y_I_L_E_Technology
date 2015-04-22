
#import "NYXImagesHelper.h"

@interface UIImage (NYX_Filtering)

/**
 *  按比例高亮图片
 *
 *  @param factor 比例
 *
 *  @return 新图片
 */
- (UIImage *)brightenWithValue:(float)factor;

/**
 *  按比例增加对比度
 *
 *  @param value 比例
 *
 *  @return 新图片
 */
- (UIImage *)contrastAdjustmentWithValue:(float)value;

- (UIImage *)edgeDetectionWithBias:(NSInteger)bias;

- (UIImage *)embossWithBias:(NSInteger)bias;

- (UIImage *)gammaCorrectionWithValue:(float)value;

/**
 *  灰度
 *
 *  @return 新图片
 */
- (UIImage *)grayscale;

/**
 *  翻转
 *
 *  @return 新图片
 */
- (UIImage *)invert;

- (UIImage *)opacity:(float)value;

- (UIImage *)sepia;

- (UIImage *)sharpenWithBias:(NSInteger)bias;

- (UIImage *)unsharpenWithBias:(NSInteger)bias;

@end
