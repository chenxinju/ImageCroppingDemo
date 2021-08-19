//
//  CXPhotosSaveImageTool.h
//  ImageCroppingDemo
//
//  Created by iOS1 on 2020/9/19.
//  Copyright © 2020 mac. All rights reserved.
//图片保存相册工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PhotosSaveImageMode) {
    PhotosSaveImageModeDelegate = 0,/**< 是通过协议去调的**/
    
    PhotosSaveImageModeBlock  = 1,/**< 是通过Block协议去调的**/
};

//失败的提示码
typedef NS_ENUM(NSUInteger, PhotosSaveImageTypeMsge){
   
    PhotosSaveImageTypeMsgePermission = 0,//没有访问相册的权限
    
    PhotosSaveImageTypeMsgeSaveNot ,//保存失败
    
    PhotosSaveImageTypeMsgeNotNetwork,//没有网络
    
    PhotosSaveImageTypeMsgePartSaveNot, /**<一部分保存失败*/
    
    PhotosSaveImageTypeMsgeCreatedCollectionNot, /**<创建相册失败*/
    
    PhotosSaveImageTypeMsgeSucceed /**<保存成功*/
};

/*
 关于 iOS14 Limited Photo 模式时，在特定界面（例如设置页）显示修改资源的入口，当用户主动点击该入口时弹出系统弹窗。
 
 首先我们需要关闭系统自动弹窗：在 Info.plist 文件中添加新键 PHPhotoLibraryPreventAutomaticLimitedAccessAlert，设置其值为 YES：
 */
typedef NS_ENUM(NSUInteger,LQBPrivacyPermissionAuthorizationStatus) {
    LQBPrivacyPermissionAuthorizationStatusAuthorized = 0,  //已经授权
    LQBPrivacyPermissionAuthorizationStatusDenied,  //用户拒绝当前应用访问相册(用户当初点击了"不允许")
    LQBPrivacyPermissionAuthorizationStatusNotDetermined,  // 用户还没有做出选择 弹框请求用户授权
    LQBPrivacyPermissionAuthorizationStatusRestricted,  //因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
    LQBPrivacyPermissionAuthorizationStatusLimited,  //iOS14新增 用户户选择了 指定图片访问
    LQBPrivacyPermissionAuthorizationStatusLocationAlways,
    LQBPrivacyPermissionAuthorizationStatusLocationWhenInUse,
    LQBPrivacyPermissionAuthorizationStatusUnkonwn,
};

/**
 保存图片的进度

 @param receivedSize 当前保存的张数
 @param expectedSize 预计要保存的个数
 */
typedef void(^SaveImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void(^PhotosSaveImageBlock)( PhotosSaveImageTypeMsge saveType,NSString *info);

@protocol PhotosSaveImageDelegate <NSObject>

@optional
//失败的回调
- (void)saveImageComeToPhotosLabraryResult:(PhotosSaveImageTypeMsge)SaveType;

/**
 保存图片

 @param receivedSize 当前保存到哪张图
 @param expectedSize expectedSize description
 */
- (void)saveImageProgressReceivedSize:(NSInteger )receivedSize ExpectedSize:(NSInteger)expectedSize;


@end

@interface CXPhotosSaveImageTool : NSObject

/**
 快速保存本地图片

 @param images 图片数组必须是图片
 @param photosName 创建相册 ，如果穿nil保存到系统相册
 @param progressBlock 保存的进度
 @param saveImageBlock 保存的结果回调
 */
+(void)saveImages:(NSArray <UIImage *>*)images withPhotosName:(NSString *)photosName saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock;


/**
 快速保存网络图片

 @param urlImages 图片的url
 @param photosNmae 相册名字
 @param progressBlock 进度的回调
 @param saveImageBlock 完成的状态判断
 */
+(void)saveImageUrls:(NSArray <NSString *>*)urlImages withPhotosName:(NSString * __nullable)photosNmae saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock;





//保存的协议
@property (weak, nonatomic) id<PhotosSaveImageDelegate> delegateSave;


/**
 相册的名字
 */
@property (nonatomic, strong) NSString *photosName;

/**
 本地图数组
 */
@property (nonatomic, strong) NSArray <UIImage *> *imageArray;

/**
 网络图数组
 */
@property (nonatomic, strong) NSArray  <NSString *> *imageUrlArray;


/**
 开始保存网络图片
 */
- (void)startSaveUrlImage;

/**
 保存本地图
 */
- (void)startSaveLoadImage;
@end



//使用示例

/*
 NSArray *array = @[@"http://wx3.sinaimg.cn/mw690/006p5ID.jpg", @"http://wx3.sinaimg.cn/mw690/006p5ID7gy1f.jpg"];
 
 [PhotosSaveImage SaveImageUrls:array withPhotosName:@"test" saveingProgress:^(NSInteger receivedSize, NSInteger expectedSize) {
     
      NSLog(@"-->保存到第%ld张", receivedSize);
     
 } compeleteSave:^(PhotosSaveImageTypeMsge saveType) {
     switch (saveType) {
         case PhotosSaveImageTypeMsgeSaveNot:
         {
             NSLog(@"-->全部保存失败");
         }
             break;
         case PhotosSaveImageTypeMsgeSucceed:
         {
             NSLog(@"-->全部保存成功");
         }
             break;
         case PhotosSaveImageTypeMsgeNotNetwork:
         {
             NSLog(@"-->没有网络");
         }
             break;
         case PhotosSaveImageTypeMsgePermission:
         {
             NSLog(@"-->提示没有访问相册的权限");
         }
             break;
             
         case PhotosSaveImageTypeMsgeCreatedCollectionNot:
         {
             NSLog(@"-->创建相册失败");
         }
             break;
         default:
             break;
     }
     
 
 }];
 
 */



NS_ASSUME_NONNULL_END
