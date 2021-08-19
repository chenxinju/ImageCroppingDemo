//
//  CXImagePicker.m
//  ImageCroppingDemo
//
//  Created by XJdeveloperMini on 2020/4/2.
//  Copyright © 2020 mac. All rights reserved.
//

#import "CXImagePicker.h"
#import "EncodeUtil.h"


@interface CXImagePicker()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation CXImagePicker

static CXImagePicker *picker = nil;
static dispatch_once_t onceToken;

+ (instancetype)shareInstanced{
    dispatch_once(&onceToken, ^{
        if (!picker) {
            picker = [[[self class] alloc] init];
        }
    });
    return picker;
}

- (instancetype)init{
    if (self = [super init]) {
        self.operationOriginImage = NO;
    }
    return self;
}

- (void)showActionSheet{
    if (self.isShowing || [[self.class topViewController] isKindOfClass:[UIAlertController class]]) {
        return;
    }
    self.isShowing = YES;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isShowing = NO;
        [self selectPhotoPickerType:CXImagePicker_Camera];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isShowing = NO;
        [self selectPhotoPickerType:CXImagePicker_Libray];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.isShowing = NO;
    }];
    
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [alertController addAction:cancelAction];
    
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover) {
        popover.sourceView = [CXImagePicker topViewController].view;
        popover.sourceRect = CGRectMake(CGRectGetWidth([CXImagePicker topViewController].view.bounds)/2 - 200, CGRectGetHeight([CXImagePicker topViewController].view.bounds)/2 - 100, 100, 100);
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [[CXImagePicker topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (UIViewController *)topViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    return [self.class topViewController:rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self topViewController:viewController.presentedViewController];
        
    } else if([viewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *) viewController;
        return [self topViewController:navigationController.visibleViewController];
        
    } else if([viewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self topViewController:tabBarController.selectedViewController];
        
    } else {
        return viewController;
    }
}


+ (CXImagePicker *)showPickerImageBlock:(PikerImageBlock)imageBlock
                              dataBlock:(PikerDataBlock)dataBlock
{
    return [CXImagePicker showPickerOriginImage:NO pixelCompress:NO maxPixel:MAXFLOAT jpegCompress:YES maxSize:MAXFLOAT ImageBlock:imageBlock dataBlock:dataBlock];
}

+ (CXImagePicker *)showPickerJpegMaxSize:(CGFloat)maxSize
                               ImageBlock:(PikerImageBlock)imageBlock
                                dataBlock:(PikerDataBlock)dataBlock
{
    return [CXImagePicker showPickerOriginImage:NO
                                  pixelCompress:NO
                                       maxPixel:0
                                   jpegCompress:YES
                                     maxSize:maxSize
                                     ImageBlock:imageBlock
                                      dataBlock:dataBlock];
}


+ (CXImagePicker *)showPickerMaxPixel:(CGFloat)maxPixel
                           ImageBlock:(PikerImageBlock)imageBlock
                            dataBlock:(PikerDataBlock)dataBlock
{
    return [CXImagePicker showPickerOriginImage:NO
                                  pixelCompress:YES
                                       maxPixel:maxPixel
                                   jpegCompress:NO
                                     maxSize:0
                                     ImageBlock:imageBlock
                                      dataBlock:dataBlock];
}


+ (CXImagePicker *)showPickerOriginImage:(BOOL)originImage
                           pixelCompress:(BOOL)pixelCompress
                                maxPixel:(CGFloat)maxPixel
                            jpegCompress:(BOOL)jpegCompress
                              maxSize:(CGFloat)maxSize
                              ImageBlock:(PikerImageBlock)imageBlock
                               dataBlock:(PikerDataBlock)dataBlock
{
    CXImagePicker *imagePicker = [CXImagePicker shareInstanced];
    
    if ([[self.class topViewController] isKindOfClass:[UIAlertController class]]) {
        return imagePicker;
    }
    
    [imagePicker showPickerOriginImage:originImage pixelCompress:pixelCompress maxPixel:maxPixel jpegCompress:jpegCompress maxSize:maxSize];
    imagePicker.imageBlock = imageBlock;
    imagePicker.dataBlock = dataBlock;
    return imagePicker;
}

- (void)showPickerOriginImage:(BOOL)originImage
                pixelCompress:(BOOL)pixelCompress
                     maxPixel:(CGFloat)maxPixel
                 jpegCompress:(BOOL)jpegCompress
                   maxSize:(CGFloat)maxSize
{
    self.pixelCompress = pixelCompress;
    self.maxPixel = maxPixel;
    self.jpegCompress = jpegCompress;
    self.maxSize = maxSize;
    [self showActionSheet];
}

- (void)selectPhotoPickerType:(CXImagePickerType)imagePickerType
{
    UIImagePickerController* pickerController = nil;;
    pickerController = [[UIImagePickerController alloc] init];
    
    pickerController.delegate = self;
    pickerController.allowsEditing = self.allowsEditing;
    
    if (imagePickerType == CXImagePicker_Camera) {
        //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    } else if (imagePickerType == CXImagePicker_Libray) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [[[self class] topViewController] presentViewController:pickerController animated:YES completion:nil];
}

- (NSData*)compressImage:(UIImage*)originImage
           pixelCompress:(BOOL)pixelCompress
                maxPixel:(CGFloat)maxPixel
            jpegCompress:(BOOL)jpegCompress
              maxSize: (CGFloat)maxSize
{
    /*
     压缩策略： 支持最多921600个像素点
     像素压缩：（调整像素点个数）
     当图片长宽比小于3:1 or 1:3时，图片长和宽最多为maxPixel像素；
     当图片长宽比在3:1 和 1:3之间时，会保证图片像素压缩到921600像素以内；
     JPEG压缩：（调整每个像素点的存储体积）
     默认压缩比0.99;
     如果压缩后的数据仍大于IMAGE_MAX_BYTES，那么将调整压缩比将图片压缩至IMAGE_MAX_BYTES以下。
     策略调整：
     不进行像素压缩，或者增大maxPixel，像素损失越小。
     使用无损压缩，或者增大IMAGE_MAX_BYTES.
     注意：
     jepg压缩比为0.99时，图像体积就能压缩到原来的0.40倍了。
     */
    UIImage * scopedImage = nil;
    NSData * resultData = nil;
    //CGFloat maxbytes = maxKB * 1024;
    
    if (originImage == nil) {
        return nil;
    }
     
    //定义临时变量记录 实际像素大小
    CGFloat actualPixel = maxPixel;
    //获取UIImage图片的像素尺寸
       CGFloat fixelW = CGImageGetWidth(originImage.CGImage);
       CGFloat fixelH = CGImageGetHeight(originImage.CGImage);
    
    
       NSLog(@"图片像素值-----fixelW=%.2f\fixelH=%.2f",fixelW,fixelH);
    if (fixelW < maxPixel || fixelH < maxPixel) {
        
         actualPixel = fixelH > fixelW ? fixelH : fixelW;
    }
    
    NSLog(@"实际压缩像素值------%.2f",actualPixel);
    
    if ( pixelCompress == YES ) {    //像素压缩
        // 像素数最多为maxPixel*maxPixel个
        CGFloat photoRatio = originImage.size.height / originImage.size.width;
        if ( photoRatio < 0.3333f )
        {                           //解决宽长图的问题
            CGFloat FinalWidth = sqrt ( actualPixel*actualPixel/photoRatio );
            scopedImage = [EncodeUtil convertImage:originImage scope:MAX(FinalWidth, actualPixel) maxPixel:maxPixel];
        }
        else if ( photoRatio <= 3.0f )
        {                           //解决高长图问题
            scopedImage = [EncodeUtil convertImage:originImage scope: actualPixel maxPixel:maxPixel];
        }
        else
        {                           //一般图片
            CGFloat FinalHeight = sqrt ( actualPixel*actualPixel*photoRatio );
            scopedImage = [EncodeUtil convertImage:originImage scope:MAX(FinalHeight, actualPixel) maxPixel:maxPixel];
        }
    }
    else {          //不进行像素压缩
        scopedImage = originImage;
    }
    
    if ( jpegCompress == YES ) {     //JPEG压缩
        resultData = [CXImagePicker compressWithImage:scopedImage maxLength:actualPixel ];
    }
    else {
        resultData = UIImageJPEGRepresentation(scopedImage, 1.0);
    }
    
    return resultData;
}

- (void)operationImagePhotoInfo:(NSDictionary *)info
{
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *resultData = nil;
    UIImage *resultImage = nil;
    if (!self.operationOriginImage) {
        resultImage = editedImage?:originalImage;
        resultData = [self compressImage:resultImage pixelCompress:self.pixelCompress maxPixel:self.maxPixel jpegCompress:self.jpegCompress maxSize:self.maxSize];
    }
    else{
        resultImage = originalImage;
        resultData = [self compressImage:resultImage pixelCompress:self.pixelCompress maxPixel:self.maxPixel jpegCompress:self.jpegCompress maxSize:self.maxSize];
    }
    if (self.imageBlock) {
        self.imageBlock(resultImage, self);
    }
    
    if (self.dataBlock) {
        self.dataBlock(resultData, self);
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self operationImagePhotoInfo:info];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

#pragma mark -

+ (NSData *)compressWithImage:(UIImage *)image maxLength:(NSUInteger)maxLength{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    //NSLog(@"Before compressing quality, image size = %ld KB",data.length/1024);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        //NSLog(@"Compression = %.1f", compression);
        //NSLog(@"In compressing quality loop, image size = %ld KB", data.length / 1024);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //NSLog(@"After compressing quality, image size = %ld KB", data.length / 1024);
    if (data.length < maxLength) return data;
    UIImage *resultImage = [UIImage imageWithData:data];
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        //NSLog(@"Ratio = %.1f", ratio);
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
        //NSLog(@"In compressing size loop, image size = %ld KB", data.length / 1024);
    }
    //NSLog(@"After compressing size loop, image size = %ld KB", data.length / 1024);
    return data;
}

@end


