

#import "NYXImagesHelper.h"

#import <UIKit/UIKit.h>
@interface UIImage (NYX_Masking)

/**
 *  给图片加上蒙版
 *
 *  @param mask 蒙版图片
 *
 *  @return 新图片
 */
- (UIImage *)maskWithImage:(UIImage *)mask;

@end
