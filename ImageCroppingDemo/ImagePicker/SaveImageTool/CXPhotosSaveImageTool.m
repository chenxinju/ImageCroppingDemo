//
//  CXPhotosSaveImageTool.m
//  ImageCroppingDemo
//
//  Created by iOS1 on 2020/9/19.
//  Copyright © 2020 mac. All rights reserved.
//

#import "CXPhotosSaveImageTool.h"
#import <Photos/Photos.h>

#import "SDWebImageManager.h"
#import "FLAlertView.h"

//内部使用的枚举
typedef NS_ENUM(NSUInteger,  SaveIMageModel) {
    SaveIMageModelLoading = 0,
    
    SaveIMageModelUrl
};

@interface CXPhotosSaveImageTool ()

@property (nonatomic, copy) SaveImageProgressBlock progressBlock;

@property (nonatomic, copy) PhotosSaveImageBlock saveImageBlock;

/**
 总图片数
 */
@property (nonatomic, assign) NSUInteger toatlNumber;

/**
 当前添加成功的数量
 */
@property (nonatomic, assign) NSUInteger currentSucceedNumber;

/**
 当前添加失败的数量
 */
@property (nonatomic, assign) NSUInteger currentDefeatNumber;


@property (nonatomic, assign) PhotosSaveImageMode  saveImageMode;


@property (nonatomic, strong) PHAssetCollection *createdCollection;

/**
 保存图片的模式
 */
@property (nonatomic, assign) SaveIMageModel saveModel;

/**
 用来计数
 */
@property (nonatomic, assign) NSUInteger  countNumber;

@end

@implementation CXPhotosSaveImageTool


+(void)saveImages:(NSArray <UIImage *>*)images withPhotosName:(NSString *)photosName saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock{
    
    //判断授权状态
    [self judgePhotosPermissionCompletion:^(BOOL response, LQBPrivacyPermissionAuthorizationStatus status) {
       
        switch (status) {
            case LQBPrivacyPermissionAuthorizationStatusAuthorized:  //已经授权
            {
                CXPhotosSaveImageTool *photos = [[CXPhotosSaveImageTool alloc]init];
                
                photos.progressBlock = progressBlock;
                
                photos.saveImageBlock = saveImageBlock;
                
                photos.photosName = photosName;
                
                photos.imageArray = images;
                
                photos.saveImageMode = PhotosSaveImageModeBlock;
                
                [photos startSaveLoadImage];
            }
                break;
            case LQBPrivacyPermissionAuthorizationStatusDenied: //用户拒绝当前应用访问相册(用户当初点击了"不允许")
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [FLAlertView showWithTitle:@"提示" message:@"保存图片功能需要您在本APP【设置】中授权允许打开相册访问" cancelButtonTitle:@"取消" okButtonTitle:@"去设置" handler:^(BOOL isOkButton) {
                        if (isOkButton) {
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                               [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:^(BOOL success) {
                             }];
                        }
                    }];
                });
                
            }
                break;
            case LQBPrivacyPermissionAuthorizationStatusLimited: // 用户只选择指定图片访问
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [FLAlertView showWithTitle:@"提示" message:@"您当前授权为指定照片可选\n保存图片功能需开启所有照片访问权限\n" cancelButtonTitle:@"取消" okButtonTitle:@"去开启" handler:^(BOOL isOkButton) {
                        if (isOkButton) {
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                               [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:^(BOOL success) {
                             }];
                        }
                    }];
                });
            }
                break;
                
            case LQBPrivacyPermissionAuthorizationStatusRestricted: //因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"因为系统原因，无法访问相册");
                    //[MBProgressHUD showInfo:@"因为系统原因，无法访问相册" toView:nil];
                });
            }
                break;
            case LQBPrivacyPermissionAuthorizationStatusNotDetermined: // 用户还没有做出选择 弹框请求用户授权
            {
                // 用户还没有做出选择 弹框请求用户授权
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        
                        CXPhotosSaveImageTool *photos = [[CXPhotosSaveImageTool alloc]init];
                        
                        photos.progressBlock = progressBlock;
                        
                        photos.saveImageBlock = saveImageBlock;
                        
                        photos.photosName = photosName;
                        
                        photos.imageArray = images;
                        
                        photos.saveImageMode = PhotosSaveImageModeBlock;
                        
                        [photos startSaveLoadImage];
                        
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }];
}



+(void)saveImageUrls:(NSArray <NSString *>*)urlImages withPhotosName:(NSString *)photosNmae saveingProgress:(SaveImageProgressBlock)progressBlock compeleteSave:(PhotosSaveImageBlock)saveImageBlock{
    
    //判断授权状态
    [self judgePhotosPermissionCompletion:^(BOOL response, LQBPrivacyPermissionAuthorizationStatus status) {
       
        switch (status) {
            case LQBPrivacyPermissionAuthorizationStatusAuthorized:  //已经授权
            {
                CXPhotosSaveImageTool *photos = [[CXPhotosSaveImageTool alloc]init];
                
                photos.progressBlock = progressBlock;
                
                photos.saveImageBlock = saveImageBlock;
                
                photos.photosName = photosNmae;
                
                photos.imageUrlArray = urlImages;
                
                photos.saveImageMode = PhotosSaveImageModeBlock;
                
                [photos startSaveUrlImage];
            }
                break;
            case LQBPrivacyPermissionAuthorizationStatusDenied: //用户拒绝当前应用访问相册(用户当初点击了"不允许")
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [FLAlertView showWithTitle:@"提示" message:@"保存图片功能需要您在本APP【设置】中授权允许打开相册访问" cancelButtonTitle:@"取消" okButtonTitle:@"去设置" handler:^(BOOL isOkButton) {
                        if (isOkButton) {
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                               [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:^(BOOL success) {
                             }];
                        }
                    }];
                });
                
            }
                break;
            case LQBPrivacyPermissionAuthorizationStatusLimited: // 用户只选择指定图片访问
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [FLAlertView showWithTitle:@"提示" message:@"您当前授权为指定照片可选\n保存图片功能需开启所有照片访问权限\n" cancelButtonTitle:@"取消" okButtonTitle:@"去开启" handler:^(BOOL isOkButton) {
                        if (isOkButton) {
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                               [[UIApplication sharedApplication] openURL:url options:[NSDictionary new] completionHandler:^(BOOL success) {
                             }];
                        }
                    }];
                });
            }
                break;
                
            case LQBPrivacyPermissionAuthorizationStatusRestricted: //因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[MBProgressHUD showInfo:@"因为系统原因，无法访问相册" toView:nil];
                });
            }
                break;
                
            case LQBPrivacyPermissionAuthorizationStatusNotDetermined: // 用户还没有做出选择 弹框请求用户授权
            {
                // 用户还没有做出选择 弹框请求用户授权
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        
                        CXPhotosSaveImageTool *photos = [[CXPhotosSaveImageTool alloc]init];
                        
                        photos.progressBlock = progressBlock;
                        
                        photos.saveImageBlock = saveImageBlock;
                        
                        photos.photosName = photosNmae;
                        
                        photos.imageUrlArray = urlImages;
                        
                        photos.saveImageMode = PhotosSaveImageModeBlock;
                        
                        [photos startSaveUrlImage];
                        
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }];
    
    
}


/**
 需要使用协议
 
 @param delegateSave 协议
 */
- (void)setDelegateSave:(id<PhotosSaveImageDelegate>)delegateSave{
    if (_delegateSave != delegateSave) {
        
        _delegateSave = delegateSave;
    }
    self.saveImageMode = PhotosSaveImageModeDelegate;
}
// 保存网络图
- (void)startSaveUrlImage{
    
    self.saveModel = SaveIMageModelUrl;
    self.countNumber = 0;
    [self contextPhotosPermission];
    
}


//保存本地图
- (void)startSaveLoadImage{
    
    self.saveModel = SaveIMageModelLoading;
    [self contextPhotosPermission];
    
}

//判断权限之后的处理
- (void)contextPhotosPermission{
    
    if ([self judgePhotosPermission]) {
        
        self.createdCollection = [self createdCollectionAction];
        
        if (self.createdCollection) {
            //创建建相册成功；
            self.currentSucceedNumber = 0;
            
            self.currentDefeatNumber = 0;
            
            self.toatlNumber = self.imageArray.count;
            //本地图开始保存
            if (self.saveModel == SaveIMageModelLoading) {
                [self loadingImageSaveArray];
                
            }else{
                
                [self webImageSaveArray];
            }
            
        }else{
            //创建相册失败
            [self resultCompelteType:PhotosSaveImageTypeMsgeCreatedCollectionNot];
        }
        
    }else{
        //没有权限
        [self resultCompelteType:PhotosSaveImageTypeMsgePermission];
        
    }
    
}
//处理结果
- (void)resultCompelteType:(PhotosSaveImageTypeMsge)resultType{
    
    switch (self.saveImageMode) {
            //使用的协议
        case PhotosSaveImageModeDelegate:
        {
            if (self.delegateSave && [self.delegateSave respondsToSelector:@selector(saveImageComeToPhotosLabraryResult:)]) {
                
                [self.delegateSave saveImageComeToPhotosLabraryResult:resultType];
            }
        }
            break;
            //使用的block
        case PhotosSaveImageModeBlock:
        {
            if (self.saveImageBlock) {
                NSString *infostr = @"";
                switch (resultType) {
                    case PhotosSaveImageTypeMsgeSaveNot:
                    {
                        infostr = @"全部保存失败";
                        //                        NSLog(@"-->全部保存失败");
                    }
                        break;
                    case PhotosSaveImageTypeMsgeSucceed:
                    {
                        //                        NSLog(@"-->保存成功");
                        infostr = @"保存成功";
                    }
                        break;
                    case PhotosSaveImageTypeMsgeNotNetwork:
                    {
                        //                        NSLog(@"-->没有网络");
                        infostr = @"没有网络";
                    }
                        break;
                    case PhotosSaveImageTypeMsgePermission:
                    {
                        //                        NSLog(@"-->提示没有访问相册的权限");
                        //                        infostr = @"还没有访问相册权限，无法保存，请前往设置-添加保存图片到相册权限";
                    }
                        break;
                        
                    case PhotosSaveImageTypeMsgeCreatedCollectionNot:
                    {
                        //                        NSLog(@"-->创建相册失败");
                        infostr = @"创建相册失败";
                    }
                        break;
                    default:
                        break;
                }
                
                self.saveImageBlock(resultType,infostr);
            }
        }
            break;
            
        default:
            
            break;
    }
}

/**
 相册权限判断
 
 @return 返回判断结果
 */
- (BOOL)judgePhotosPermission{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        
        return NO;
    }
    
    return YES;
    
}

/**
 相册权限判断
   返回判断结果
 */
+ (void)judgePhotosPermissionCompletion:(void(^)(BOOL response,LQBPrivacyPermissionAuthorizationStatus status))completion{
    
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusLimited:
                {
                    //用户选择Limited模式，限制App访问有限的相册资源
                    completion(NO,LQBPrivacyPermissionAuthorizationStatusLimited);
                   
                }
                    break;
                case PHAuthorizationStatusDenied:
                {
                    NSLog(@"denied");
                    // 用户还没有做出选择 弹框请求用户授权
                    completion(NO,LQBPrivacyPermissionAuthorizationStatusNotDetermined);
                }
                    break;
                case PHAuthorizationStatusAuthorized:
                {
                    //用户选择"允许访问所有照片"
                    completion(YES,LQBPrivacyPermissionAuthorizationStatusAuthorized);
                }
                    break;
                    
                case PHAuthorizationStatusRestricted:
                {
                    //因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
                    completion(YES,LQBPrivacyPermissionAuthorizationStatusRestricted);
                }
                    break;
                default:
                    break;
            }
        }];
    }else {
        
        // Fallback on earlier versions
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusDenied) {
                completion(NO,LQBPrivacyPermissionAuthorizationStatusDenied);
            } else if (status == PHAuthorizationStatusNotDetermined) {
                // 用户还没有做出选择 弹框请求用户授权
                completion(NO,LQBPrivacyPermissionAuthorizationStatusNotDetermined);
            } else if (status == PHAuthorizationStatusRestricted) {
                //因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
                completion(NO,LQBPrivacyPermissionAuthorizationStatusRestricted);
            } else if (status == PHAuthorizationStatusAuthorized) {
                completion(YES,LQBPrivacyPermissionAuthorizationStatusAuthorized);
            }
        }];
    }
    
   
    
}


/**
 *  获得【自定义相册】
 */
- (PHAssetCollection *)createdCollectionAction
{
    
    NSString *title;
    if (self.photosName && ![self.photosName isEqualToString:@""]) {
        //自定义的名字
        title = [NSString stringWithFormat:@"%@", self.photosName];
    }else{
        // 获取软件的名字作为相册的标题
        title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    }
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //遍历出已经创建好的相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册(同步操作)
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

//网络图图片保存  使用递归来处理
-(void)webImageSaveArray{
    
    NSString *urlString;
    
    if (self.countNumber >= self.imageUrlArray.count) {
        
        [self saveCompleteJudge];
        return;
    }else{
        
        urlString = [NSString stringWithFormat:@"%@", [self.imageUrlArray objectAtIndex:self.countNumber]];
        self.countNumber++;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    __weak typeof(self) weakSelf = self;
    [manager loadImageWithURL:[NSURL URLWithString:urlString] options:(SDWebImageHighPriority) context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        [weakSelf imageSaveComeToPhotosInstallImage:image];
        [weakSelf progressingComTo];
        //当同步线程执行到这里weakSelf已经被释放了；
        [self webImageSaveArray];
    }];
}


- (void)saveCompleteJudge{
    
    if ((self.currentSucceedNumber == self.toatlNumber) || (self.currentDefeatNumber == 0)) {
        //保存成功
        [self resultCompelteType:PhotosSaveImageTypeMsgeSucceed];
        
    }else if(self.currentDefeatNumber == self.toatlNumber){
        //        全部保存失败
        [self resultCompelteType:PhotosSaveImageTypeMsgeSaveNot];
    }else{
        //        部分保存失败
        [self resultCompelteType:PhotosSaveImageTypeMsgePartSaveNot] ;
    }
}
//本地图片开始保存
-(void)loadingImageSaveArray{
    
    for (NSInteger i = 0; i < self.toatlNumber; i++) {
        UIImage *image = [self.imageArray objectAtIndex:i];
        [self imageSaveComeToPhotosInstallImage:image];
        
        [self progressingComTo];
    }
    //保存玩的判断
    [self saveCompleteJudge];
    
    
}


/**
 进度
 */
- (void)progressingComTo{
    
    switch (self.saveImageMode) {
        case PhotosSaveImageModeBlock:
        {
            //block
            if (self.progressBlock) {
                self.progressBlock(self.currentSucceedNumber + self.currentDefeatNumber, self.toatlNumber);
            }
        }
            break;
        case PhotosSaveImageModeDelegate:
        {
            //协议
            if (self.delegateSave && [self.delegateSave respondsToSelector:@selector(saveImageProgressReceivedSize:ExpectedSize:)]) {
                
                [self.delegateSave saveImageProgressReceivedSize:self.currentDefeatNumber + self.currentSucceedNumber ExpectedSize:self.toatlNumber];
            }
        }
            break;
            
        default:
            break;
    }
    
}
//一张张进行保存
- (void)imageSaveComeToPhotosInstallImage:(UIImage *)image{
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssetsActionImage:image];
    
    // 获得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    
    if (createdAssets == nil || createdCollection == nil) {
        
        self.currentDefeatNumber++;
        return;
    }
    
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
        
        self.currentDefeatNumber++;
    } else {
        
        self.currentSucceedNumber++;
    }
}


/**
 生成交卷的图
 
 @param image 保存的图片
 @return 相册交卷
 */
- (PHFetchResult <PHAsset *> *)createdAssetsActionImage:(UIImage *)image{
    //排除nil图
    if (!image) {
        return nil;
    }
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】同步操作
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}
@end
