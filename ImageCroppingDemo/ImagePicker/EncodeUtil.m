//
//  EncodeUtil.m
//  ImageCroppingDemo
//
//  Created by XJdeveloperMini on 2020/4/2.
//  Copyright © 2020 mac. All rights reserved.
//

#import "EncodeUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation EncodeUtil

+ (NSString *)getMD5ForStr:(NSString *)str
{
    const char *ptr = [str UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x",md5Buffer[i]];
    return output;
}

+ (UIImage *)convertImage:(UIImage *)origImage scope:(CGFloat)scope maxPixel:(CGFloat)maxPixel {
    
    NSLog(@"scope------%.2f",scope);
        UIImage *image = nil;
        CGSize size = origImage.size;
//
//        //定义临时变量记录 实际像素大小
//           CGFloat actualPixel = scope;
//           //获取UIImage图片的像素尺寸
//              CGFloat fixelW = CGImageGetWidth(origImage.CGImage);
//              CGFloat fixelH = CGImageGetHeight(origImage.CGImage);
//
//
//              NSLog(@"图片像素值-----fixelW=%.2f\fixelH=%.2f",fixelW,fixelH);
//           if (fixelW < scope || fixelH < scope) {
//
//                actualPixel = fixelH > fixelW ? fixelH : fixelW;
//           }
        
        
        if (size.width < maxPixel && size.height < maxPixel) {
            // do nothing
//            image = origImage;
//            CGFloat length = size.width;
//           if (size.width < size.height) {
//               length = size.height;
//           }
//           CGFloat f = scope/length;
//            NSInteger nw = size.width;// * f;
//           NSInteger nh = size.height;//* f;
//            CGSize newSize = CGSizeMake(nw, nh);
//              //        CGSize newSize = CGSizeMake(size.width*f, size.height*f);
//
//          //
//          UIGraphicsBeginImageContext(newSize);
//          //UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
//          // Tell the old image to draw in this new context, with the desired
//          // new size
//          [origImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//          // Get the new image from the context
//          image = UIGraphicsGetImageFromCurrentImageContext();
//          UIGraphicsEndImageContext();
            NSLog(@"-------JPEGRepresentation");
           NSData *data = UIImageJPEGRepresentation(origImage, 0.5);
            
            image = [UIImage imageWithData:data];
            
        } else {
            
            NSLog(@"-------UIGraphicsBeginImageContext");
            CGFloat length = size.width;
            if (size.width < size.height) {
                length = size.height;
            }
            CGFloat f = scope/length;
            NSInteger nw = size.width * f;
            NSInteger nh = size.height * f;
            if (nw > scope) {
                nw = scope;
            }
            if (nh > scope) {
                nh = scope;
            }

            CGSize newSize = CGSizeMake(nw, nh);
    //        CGSize newSize = CGSizeMake(size.width*f, size.height*f);
            
            //
            UIGraphicsBeginImageContext(newSize);
            //UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
            // Tell the old image to draw in this new context, with the desired
            // new size
            [origImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            // Get the new image from the context
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        return image;
}

//+ (UIImage *)convertImage:(UIImage *)origImage scope:(CGFloat)scope
//{
//    NSLog(@"scope------%.2f",scope);
//
//    if (size.width < scope && size.height < scope) {
//        // do nothing
//        image = origImage;
//    } else {
//        CGFloat length = size.width;
//        if (size.width < size.height) {
//            length = size.height;
//        }
//        CGFloat f = scope/length;
//        NSInteger nw = size.width * f;
//        NSInteger nh = size.height * f;
//        if (nw > scope) {
//            nw = scope;
//        }
//        if (nh > scope) {
//            nh = scope;
//        }
//
//        CGSize newSize = CGSizeMake(nw, nh);
////        CGSize newSize = CGSizeMake(size.width*f, size.height*f);
//
//        //
//        UIGraphicsBeginImageContext(newSize);
//        //UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
//        // Tell the old image to draw in this new context, with the desired
//        // new size
//        [origImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//        // Get the new image from the context
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    return image;
//}

@end
