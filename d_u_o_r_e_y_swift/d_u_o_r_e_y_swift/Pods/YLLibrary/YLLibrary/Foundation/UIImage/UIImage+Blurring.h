
#import "NYXImagesHelper.h"


@interface UIImage (NYX_Blurring)

/**
 *  给图片加高丝模糊
 *
 *  @param bias 值
 *
 *  @return 新图片
 */
- (UIImage *)gaussianBlurWithBias:(NSInteger)bias;

@end
