//
//  EncodeUtil.h
//  ImageCroppingDemo
//
//  Created by XJdeveloperMini on 2020/4/2.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncodeUtil : NSObject

+ (NSString *)getMD5ForStr:(NSString *)str;
//+ (UIImage *)convertImage:(UIImage *)origImage scope:(CGFloat)scope;

+ (UIImage *)convertImage:(UIImage *)origImage scope:(CGFloat)scope maxPixel:(CGFloat)maxPixel;


@end
