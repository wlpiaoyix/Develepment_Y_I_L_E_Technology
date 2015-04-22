
#import <UIKit/UIKit.h>


@interface UIScrollView (NYX_Screenshot)

/**
 *  截取UIScrollView可见区域并保存为图像
 *
 *  @return 图像
 */
- (UIImage *)imageByRenderingCurrentVisibleRect;

@end
