
#import "UIScrollView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@implementation UIScrollView (NYX_Screenshot)

- (UIImage *)imageByRenderingCurrentVisibleRect {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, -self.contentOffset.y);
	[self.layer renderInContext:context];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
