#import <UIKit/UIKit.h>

@interface UIImage (NYX_Enhancing)

/**
 *  自动调整图片
 *
 *  @return 新图片
 */
- (UIImage *)autoEnhance;

/**
 *  修正红颜
 *
 *  @return 新图片
 */
- (UIImage *)redEyeCorrection;

@end
