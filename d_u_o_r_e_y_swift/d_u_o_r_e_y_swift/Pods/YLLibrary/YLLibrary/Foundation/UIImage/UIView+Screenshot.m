
#import "UIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@implementation UIView (NYX_Screenshot)

- (UIImage *)imageByRenderingView {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
