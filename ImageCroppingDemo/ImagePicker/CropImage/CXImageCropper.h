//
//  CXImageCropper.h
//  ImageCroppingDemo
//
//  Created by iOS1 on 2021/8/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CXImageCropper;
@protocol CXImageCroppingDelegate <NSObject>

-(void)cxImageCroppingDidCancle:(CXImageCropper *)cropping;
-(void)cxImageCropping:(CXImageCropper *)cropping didCropImage:(UIImage *)image;

@end

@interface CXImageCropper : UIViewController


@property(nonatomic,weak)id<CXImageCroppingDelegate>delegate;

/**
 裁剪的图片
 */
@property(nonatomic,strong)UIImage *image;

/**
 裁剪区域
 */
@property(nonatomic,assign)CGSize cropSize;


/**
 是否裁剪成圆形
 */
@property(nonatomic,assign)BOOL isRound;

@property (nonatomic,assign) BOOL    isDark; // 是否为虚线 default is NO

@end

NS_ASSUME_NONNULL_END
