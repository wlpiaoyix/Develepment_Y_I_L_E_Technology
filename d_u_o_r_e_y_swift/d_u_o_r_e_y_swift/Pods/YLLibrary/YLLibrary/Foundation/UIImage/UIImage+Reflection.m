//
//  UIImage+Reflection.m

#import "UIImage+Reflection.h"


@implementation UIImage (NYX_Reflection)

- (UIImage *)reflectedImageWithHeight:(NSUInteger)height fromAlpha:(float)fromAlpha toAlpha:(float)toAlpha {
    if (!height)
		return nil;

	// create a bitmap graphics context the size of the image
	UIGraphicsBeginImageContextWithOptions((CGSize){.width = self.size.width, .height = height}, NO, 0.0f);
    CGContextRef mainViewContentContext = UIGraphicsGetCurrentContext();

	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection. The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = NYXCreateGradientImage(1, height, fromAlpha, toAlpha);

	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = self.size.width, .size.height = height}, gradientMaskImage);
	CGImageRelease(gradientMaskImage);

	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size = self.size}, self.CGImage);

	// convert the finished reflection image to a UIImage
	UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return theImage;
}

@end
