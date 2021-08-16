
#import <UIKit/UIKit.h>

@interface UIImage (Crop)

/**
 缩放指定大小

 @param newSize 缩放后的尺寸
 @return UIImage
 */
- (UIImage *)resizeImageWithSize:(CGSize)newSize;

/**
 图片圆形裁剪

 @return UIImage
 */
- (UIImage *)ovalClip;


/**
 *  发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小 单位K
 *
 *  @return 返回处理后的图片data
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;

@end
