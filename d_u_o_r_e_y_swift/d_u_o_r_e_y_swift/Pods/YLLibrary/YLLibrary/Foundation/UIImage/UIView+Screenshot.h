#import <UIKit/UIKit.h>

@interface UIView (NYX_Screenshot)

/**
 *  截取当前屏幕并保存为图片
 *
 *  @return 图片
 */
- (UIImage *)imageByRenderingView;

@end
