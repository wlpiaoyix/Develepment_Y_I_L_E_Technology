
#import "NYXImagesHelper.h"


@interface UIImage (NYX_Reflection)

/**
 *  按高度、起始透明值、结尾透明值放射图片
 *
 *  @param height    高度
 *  @param fromAlpha 起始透明值
 *  @param toAlpha   结尾透明值
 *
 *  @return 反射后的图片
 */
- (UIImage *)reflectedImageWithHeight:(NSUInteger)height fromAlpha:(float)fromAlpha toAlpha:(float)toAlpha;

@end
