//
//  CXImagePickerVc.m
//  ImageCroppingDemo
//
//  Created by XJdeveloper on 2018/4/10.
//  Copyright © 2018年 XJdeveloper. All rights reserved.
//

#import "CXImagePickerVc.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CropImageController.h"
#import "UIImage+Crop.h"

//主线程
#define GCDMain(block)       dispatch_async(dispatch_get_main_queue(),block)

@interface CXImagePickerVc () <UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate>

@property (nonatomic, strong)UIViewController *presentViewController;
@property (nonatomic, strong) UIImagePickerController * pickerController;
@property (nonatomic, strong)UTImagePickerCompletion completion;
@property (nonatomic, assign)CGFloat compressionQuality;  //压缩质量
@property (nonatomic, assign) BOOL allowsEditing;
@end


@implementation CXImagePickerVc


+ (instancetype)shareImagePicker {
    static CXImagePickerVc *shareImagePicker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareImagePicker = [[CXImagePickerVc alloc] init];
    });
    return shareImagePicker;
}

/**
 *  显示ActionSheet， “拍照”、“从相册中选取”
 *
 *  @param presentViewController 传入要显示相机的页面
 *  @param completion            获取相片完成执行的block对象
 *  @param compressionQuality    The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
 */
- (void)showActionSheetWithPresentViewController:(UIViewController *)presentViewController
                         didFinishWithCompletion:(UTImagePickerCompletion)completion
                              compressionQuality:(CGFloat)compressionQuality
                                   allowsEditing:(BOOL)allowsEditing{
    self.completion = completion;
    self.compressionQuality = compressionQuality;
    self.presentViewController = presentViewController;
    self.allowsEditing = allowsEditing;
    
    //        WEAKSELF
    LCActionSheet *sheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) return ;
        
        switch (buttonIndex) {
            case 1:
            {
                [self openCameraWithPresentViewController:self.presentViewController
                                  didFinishWithCompletion:self.completion
                                       compressionQuality:self.compressionQuality
                                            allowsEditing:self.allowsEditing];
            }
                break;
            case 2:
            {
                
                [self openPhotoLibraryWithPresentViewController:self.presentViewController
                                        didFinishWithCompletion:self.completion
                                             compressionQuality:self.compressionQuality
                                                  allowsEditing:self.allowsEditing];
            }
                break;
                
            default:
                break;
        }
    } otherButtonTitles:@"拍照",@"从相册中选择", nil];
    [sheet show];
}

- (void)showActionSheetWithPresentViewController:(UIViewController *)presentViewController
                         didFinishWithCompletion:(UTImagePickerCompletion)completion
                              compressionQuality:(CGFloat)compressionQuality{
    [self showActionSheetWithPresentViewController:presentViewController
                           didFinishWithCompletion:completion
                                compressionQuality:compressionQuality
                                     allowsEditing:YES];
}

- (void)showActionSheetWithPresentViewController:(UIViewController *)presentViewController
                         didFinishWithCompletion:(UTImagePickerCompletion)completion
                                   allowsEditing:(BOOL)allowsEditing{
    [self showActionSheetWithPresentViewController:presentViewController
                           didFinishWithCompletion:completion
                                compressionQuality:0
                                     allowsEditing:allowsEditing];
}

- (void)showActionSheetWithPresentViewController:(UIViewController *)presentViewController
                         didFinishWithCompletion:(UTImagePickerCompletion)completion{
    [self showActionSheetWithPresentViewController:presentViewController
                           didFinishWithCompletion:completion
                                compressionQuality:0
                                     allowsEditing:NO];
}


/**
 *  开启相机
 *
 *  @param presentViewController 传入要显示相机的页面
 *  @param completion            获取相片完成执行的block对象
 *  @param compressionQuality    The quality of the resulting JPEG image, expressed as a value from 0.0 to 1.0. The value 0.0 represents the maximum compression (or lowest quality) while the value 1.0 represents the least compression (or best quality).
 */
- (void)openCameraWithPresentViewController:(UIViewController *)presentViewController
                    didFinishWithCompletion:(UTImagePickerCompletion)completion
                         compressionQuality:(CGFloat)compressionQuality
                              allowsEditing:(BOOL)allowsEditing{
    
    self.completion = completion;
    self.compressionQuality = compressionQuality;
    self.presentViewController = presentViewController;
    self.allowsEditing = allowsEditing;
    
    // 拍照
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {  // 无权限
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"支持相机请前往\n系统设置-隐私-相机\n进行修改权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openURLWithString:UIApplicationOpenSettingsURLString];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:setAction];
            [presentViewController presentViewController:alertController animated:YES completion:nil];
            return;
        } else {
            GCDMain(^{
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.modalPresentationStyle = UIModalPresentationFullScreen;
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;//UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
//              controller.allowsEditing = self.allowsEditing;  //是否可编辑裁剪
                 self.pickerController = controller;
                //跳转到相机
                [presentViewController presentViewController:controller animated:YES completion:nil];
            });
        }
    }
}

- (void)openPhotoLibraryWithPresentViewController:(UIViewController *)presentViewController
                          didFinishWithCompletion:(UTImagePickerCompletion)completion
                               compressionQuality:(CGFloat)compressionQuality
                                    allowsEditing:(BOOL)allowsEditing{
    self.completion = completion;
    self.compressionQuality = compressionQuality;
    self.presentViewController = presentViewController;
    self.allowsEditing = allowsEditing;
    
    // 从相册中选取
    if ([self isPhotoLibraryAvailable]) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ) {
        
            NSLog(@"因为系统原因，无法访问相册");
            
        }else if (status == PHAuthorizationStatusDenied){

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"支持相册使用需前往系统设置app相册访问" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openURLWithString:UIApplicationOpenSettingsURLString];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:setAction];
            
            [presentViewController presentViewController:alertController animated:YES completion:nil];
            
        }else if (status == PHAuthorizationStatusAuthorized){
            
            [self openImagePickerWithPresentViewController:presentViewController];
            
        }else if (status == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self openImagePickerWithPresentViewController:presentViewController];
                }
            }];
        }
        
    }
}

- (void)openImagePickerWithPresentViewController:(UIViewController *)presentViewController {
    
    GCDMain(^{
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypesArray = [[NSMutableArray alloc] init];
        [mediaTypesArray addObject:(__bridge NSString *)kUTTypeImage];
        pickerController.mediaTypes = mediaTypesArray;
        pickerController.delegate = self;
//       pickerController.showsCameraControls = YES; //拍照自定义
//       pickerController.allowsEditing = self.allowsEditing;
        self.pickerController = pickerController;
        //跳转到相册
        [presentViewController presentViewController:pickerController animated:YES completion:nil];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.pickerController = picker;
    /*  内部跳转去裁剪
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = image.size.height * (width/image.size.width);
    UIImage * orImage = [image resizeImageWithSize:CGSizeMake(width, height)];
    CropImageController * con = [[CropImageController alloc] initWithImage:orImage delegate:self];
    con.modalPresentationStyle = UIModalPresentationFullScreen;
    con.ovalClip = NO; //YES：圆形
    [picker presentViewController:con animated:YES completion:^{
       
    }];
     */
    /*选择完成回调 外部处理*/
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *image;
        if (self.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        image = [CXImagePickerVc fixOrientation:image];
        
        NSData * imageData;
        if (self.compressionQuality == 0) {
            imageData = [UIImage resetSizeOfImageData:image maxSize:600];
        }else{
            imageData = UIImageJPEGRepresentation(image, self.compressionQuality);
        }
        self.completion(picker, info, image, imageData);
    }];
     
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"取消");
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.cameraCancelBlock) {
            weakSelf.cameraCancelBlock();
        }
        
    }];
}
#pragma mark -- CropImageDelegate
- (void)cropImageDidFinishedWithImage:(UIImage *)image {
    NSData * imageData;
   if (self.compressionQuality == 0) {
       imageData = [UIImage resetSizeOfImageData:image maxSize:600];
   }else{
       imageData = UIImageJPEGRepresentation(image, self.compressionQuality);
   }
    self.completion(nil, nil, image, imageData);
//    [self.presentViewController dismissViewControllerAnimated:YES completion:nil];
    UIViewController *vc = self.pickerController;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{//相机
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

//是否支持前置摄像头
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
//是否支持后置摄像头
- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

//是否支持相机
- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

//图片库
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

+ (UIImage *)fixOrientation:(UIImage *)orgImage {
    
    // No-op if the orientation is already correct
    
    if (orgImage.imageOrientation == UIImageOrientationUp) return orgImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orgImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, orgImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, orgImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    switch (orgImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, orgImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, orgImage.size.width, orgImage.size.height,
                                             CGImageGetBitsPerComponent(orgImage.CGImage), 0,
                                             CGImageGetColorSpace(orgImage.CGImage),
                                             CGImageGetBitmapInfo(orgImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orgImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,orgImage.size.height,orgImage.size.width), orgImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,orgImage.size.width,orgImage.size.height), orgImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (void)openURLWithString:(NSString *)url
{
    NSURL *appUrl = [NSURL URLWithString:url];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:appUrl options:@{UIApplicationOpenURLOptionsOpenInPlaceKey:@"1"} completionHandler:^(BOOL success) {
            if(!success) {
            }
        }];
    } else {
        
        // Fallback on earlier versions
        BOOL result = [[UIApplication sharedApplication] canOpenURL:appUrl];
        if(result ==YES) {
            [[UIApplication sharedApplication] openURL:appUrl];
        }
    }
}

@end
