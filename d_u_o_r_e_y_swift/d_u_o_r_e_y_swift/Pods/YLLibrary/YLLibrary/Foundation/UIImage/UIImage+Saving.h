
#import "NYXImagesHelper.h"

typedef enum
{
	NYXImageTypePNG,
	NYXImageTypeJPEG,
	NYXImageTypeGIF,
	NYXImageTypeBMP,
	NYXImageTypeTIFF
} NYXImageType;

@interface UIImage (NYX_Saving)

/**
 *  保存图片到特定的url地址
 *
 *  @param url       url地址
 *  @param uti       图片格式
 *  @param fillColor 背景填充颜色
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToURL:(NSURL*)url uti:(CFStringRef)uti backgroundFillColor:(UIColor*)fillColor;

/**
 *  保存图片到特定的url地址
 *
 *  @param url       url地址
 *  @param type      NYXImageType图片格式
 *  @param fillColor 背景填充颜色
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToURL:(NSURL*)url type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor;

/**
 *  保存图片到特定的url地址
 *
 *  @param url url地址
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToURL:(NSURL*)url;

/**
 *  保存图片到特定的文件路径
 *
 *  @param path      路径
 *  @param uti       图片格式
 *  @param fillColor 背景填充颜色
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToPath:(NSString*)path uti:(CFStringRef)uti backgroundFillColor:(UIColor*)fillColor;

/**
 *  保存图片到特定的文件路径
 *
 *  @param path      路径
 *  @param type      NYXImageType图片格式
 *  @param fillColor 背景填充颜色
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToPath:(NSString*)path type:(NYXImageType)type backgroundFillColor:(UIColor*)fillColor;

/**
 *  保存图片到特定的文件路径
 *
 *  @param path 路径
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToPath:(NSString*)path;

/**
 *  保存图片到相簿
 *
 *  @return 如果保存成功则返回YES
 */
- (BOOL)saveToPhotosAlbum;

/**
 *  根据UTI得到extension
 *
 *  @param uti UTI
 *
 *  @return extension
 */
+ (NSString*)extensionForUTI:(CFStringRef)uti;

@end
