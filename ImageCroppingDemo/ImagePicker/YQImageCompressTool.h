//
//  YQImageCompressTool.h
//  compressTest
//
//  Created by problemchild on 16/7/7.
//  Copyright © 2016年 ProblenChild. All rights reserved.
//
/*
 
 结合了“只压不缩”和“只缩不压”来做的“压缩”，在保证达到压缩目标的同时尽量保证图片质量
 由于尽可能得想要压缩出来的图片质量尽可能地高，可能压缩子程序要走很多遍，来找到最合适的情况。所以压缩耗时可能较长。推荐使用后台压缩方法
 根据不同的情况提供了两种压缩结果：1，压缩得到目标大小的NSData；2，压缩得到目标大小的UIImage
 **提示：**在iOS端使用NSData创建得到的UIImage大小会比原NSData要大，所以根据具体需要目标大小的Data还是目标大小的Image，可以选择不同的方法。
 */
#import <UIKit/UIKit.h>

@interface YQImageCompressTool : NSObject

typedef void(^ImgBlock) (UIImage *resultImage);
typedef void(^DataBlock)(NSData  *resultData);

#pragma mark --------前台压缩（可能比较慢，造成当前进程卡住）
/**
 *  压缩得到 目标大小的 图片Data
 *
 *  @param OldImage 原图
 *  @param ShowSize 将要显示的分辨率
 *  @param FileSize 文件大小限制
 *
 *  @return 压缩得到的图片Data
 */
+(NSData *)CompressToDataWithImage:(UIImage *)OldImage
                          ShowSize:(CGSize)ShowSize
                          FileSize:(NSInteger)FileSize;
/**
 *  压缩得到 目标大小的 UIImage
 *
 *  @param OldImage 原图
 *  @param ShowSize 将要显示的分辨率
 *  @param FileSize 文件大小限制
 *
 *  @return 压缩得到的UIImage
 */
+(UIImage *)CompressToImageWithImage:(UIImage *)OldImage
                            ShowSize:(CGSize)ShowSize
                            FileSize:(NSInteger)FileSize;

#pragma mark --------后台压缩（异步进行，不会卡住前台进程）

/**
 *  后台压缩得到 目标大小的 图片Data
    (使用block的结果，记得按需获取主线程)
 *
 *  @param OldImage  原图
 *  @param ShowSize  将要显示的分辨率
 *  @param FileSize  文件大小限制
 *  @param DataBlock 压缩成功后返回的block
 */
+(void)CompressToDataAtBackgroundWithImage:(UIImage *)OldImage
                                      ShowSize:(CGSize)ShowSize
                                      FileSize:(NSInteger)FileSize
                                         block:(DataBlock)DataBlock;


/**
 *  后台压缩得到 目标大小的 UIImage
    (使用block的结果，记得按需获取主线程)
 *
 *  @param OldImage 原图
 *  @param ShowSize 将要显示的分辨率
 *  @param FileSize 文件大小限制
 *  @param ImgBlock 压缩成功后返回的block
 */
+(void)CompressToImageAtBackgroundWithImage:(UIImage *)OldImage
                                        ShowSize:(CGSize)ShowSize
                                        FileSize:(NSInteger)FileSize
                                           block:(ImgBlock)ImgBlock;

#pragma mark --------细化调用方法
//------只压不缩--按UIImage大小压缩，返回UIImage
//优点：不影响分辨率，不太影响清晰度
//缺点：存在最小限制，可能压不到目标大小
+ (UIImage *)OnlyCompressToImageWithImage:(UIImage *)OldImage
                                 FileSize:(NSInteger)FileSize;

//------只压不缩--按NSData大小压缩，返回NSData
//优点：不影响分辨率，不太影响清晰度
//缺点：存在最小限制，可能压不到目标大小
//默认PNG
+ (NSData *)OnlyCompressToDataWithImage:(UIImage *)OldImage
                               FileSize:(NSInteger)FileSize;


//------只缩不压
//优点：可以大幅降低容量大小
//缺点：影响清晰度
//若Scale为YES，则原图会根据Size进行拉伸-会变形
//若Scale为NO，则原图会根据Size进行填充-不会变形
+(UIImage *)ResizeImageWithImage:(UIImage *)OldImage
                         andSize:(CGSize)Size
                           Scale:(BOOL)Scale;


@end
