
#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)resizeImageWithSize:(CGSize)newSize {
    CGFloat newWidth = newSize.width;
    CGFloat newHeight = newSize.height;
    float width  = self.size.width;
    float height = self.size.height;
    if (width != newWidth || height != newHeight) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), YES, [UIScreen mainScreen].scale);
        [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        
        UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resized;
    }
    return self;
}
- (UIImage *)ovalClip {

    CGSize size = self.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [path addClip];
    [self drawAtPoint:CGPointZero];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 *  发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小 单位K
 *
 *  @return 返回处理后的图片data
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData;
        if (sizeOriginKB < 1024) {
            finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        }
        else if (sizeOriginKB > 1024) {
            finallImageData = UIImageJPEGRepresentation(newImage,0.40);
        }
        else if (sizeOriginKB > 1024 * 4) {
            finallImageData = UIImageJPEGRepresentation(newImage,0.30);
        }
        else if (sizeOriginKB > 1024 * 6) {
            finallImageData = UIImageJPEGRepresentation(newImage,0.20);
        }
        else{
            finallImageData = UIImageJPEGRepresentation(newImage,0.10);
        }
        
        return finallImageData;
    }
    
    return imageData;
}

@end
