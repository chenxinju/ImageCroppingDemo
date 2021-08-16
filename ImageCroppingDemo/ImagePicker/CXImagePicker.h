//
//  CXImagePicker.h
//  ImageCroppingDemo
//
//  Created by XJdeveloperMini on 2020/4/2.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_MAXIMUM_BYTES 1024000.0f   // 1024000 = 1000 * 1024 bytes

typedef enum : NSUInteger {
    CXImagePicker_Camera,
    CXImagePicker_Libray,
} CXImagePickerType;


typedef void(^mm)(NSString *s);
typedef void(^PikerImageBlock)(UIImage *image, id picker);
typedef void(^PikerDataBlock)(NSData *data, id picker);

@interface CXImagePicker : NSObject

@property (nonatomic, copy) PikerImageBlock imageBlock;
@property (nonatomic, copy) PikerDataBlock dataBlock;
@property (nonatomic, assign) BOOL operationOriginImage;
@property (nonatomic, assign) BOOL pixelCompress;
@property (nonatomic, assign) CGFloat maxPixel;
@property (nonatomic, assign) BOOL jpegCompress;
@property (nonatomic, assign) CGFloat maxSize;

@property (nonatomic, assign) BOOL isShowing ;
@property (nonatomic, assign) BOOL allowsEditing;
// 使用自定义拍摄界面
/**
 * 建议pad 只支持 系统原生播放器。因为自定义图片会拉大。 也就是pad useAVSessionImagePiker=NO;
 */
@property (nonatomic, assign) BOOL useAVSessionImagePiker;

+ (instancetype)shareInstanced;




+ (UIViewController *)topViewController;

/**
 *  选择图片回调代理，不进行压缩
 */
+ (CXImagePicker *)showPickerImageBlock:(PikerImageBlock)imageBlock
                              dataBlock:(PikerDataBlock)dataBlock;



/*
 *    @param     originImage        处理原始图片 默认为NO
 *    @param     jpegCompress       是否进行JPEG压缩,jpeg 压缩会更肖
 *    @param     max               图片最大体积，以字节为单位
 *
 */
+ (CXImagePicker *)showPickerJpegMaxSize:(CGFloat)maxSize
                               ImageBlock:(PikerImageBlock)imageBlock
                                dataBlock:(PikerDataBlock)dataBlock;

/*
 *    @param   maxPixel  最大宽或者高尺寸像素，如果宽长，则指的是宽，如果高长，则指的是高
 *
 */
+ (CXImagePicker *)showPickerMaxPixel:(CGFloat)maxPixel
                           ImageBlock:(PikerImageBlock)imageBlock
                            dataBlock:(PikerDataBlock)dataBlock;


/*
 *  @param       originImage    处理原始图片 默认为NO
 *    @param     pixelCompress  是否进行像素压缩
 *    @param     maxPixel       最大宽或者高尺寸像素，如果宽长，则指的是宽，如果高长，则指的是高；pixelCompress=NO时，此参数无效。
 *    @param     jpegCompress   是否进行JPEG压缩,jpeg 压缩会更肖
 *    @param     maxKB          图片最大体积，以KB为单位；jpegCompress=NO时，此参数无效。
 *
 */
+ (CXImagePicker *)showPickerOriginImage:(BOOL)originImage
                           pixelCompress:(BOOL)pixelCompress
                                maxPixel:(CGFloat)maxPixel
                            jpegCompress:(BOOL)jpegCompress
                                 maxSize:(CGFloat)maxSize
                              ImageBlock:(PikerImageBlock)imageBlock
                               dataBlock:(PikerDataBlock)dataBlock;

/*
 *    @brief    压缩图片 @Fire
 *
 *    @param     originImage       原始图片
 *    @param     pixelCompress     是否进行像素压缩
 *    @param     maxPixel          最大宽或者高尺寸像素，如果宽长，则指的是宽，如果高长，则指的是高；pixelCompress=NO时，此参数无效。
 *    @param     jpegCompress      是否进行JPEG压缩,jpeg 压缩会更肖
 *    @param     maxKB             图片最大体积，以KB为单位；jpegCompress=NO时，此参数无效。
 *
 *    @return    返回图片的NSData
 */
- (NSData*)compressImage:(UIImage*)originImage
           pixelCompress:(BOOL)pixelCompress
                maxPixel:(CGFloat)maxPixel
            jpegCompress:(BOOL)jpegCompress
              maxSize:(CGFloat)maxSize;


- (void)selectPhotoPickerType:(CXImagePickerType)imagePickerType;
- (void)showActionSheet;


@end



