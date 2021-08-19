//
//  FLAlertButton.h
//  ImageCroppingDemo
//
//  Created by mac on 2020/2/10.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLAlertButtonStyle) {
    FLAlertButtonStyleDefault = 0,
    FLAlertButtonStyleCancel,
    FLAlertButtonStyleDestructive
};

@interface FLAlertButton : UIButton

@property (nonatomic, strong) UIColor *defaultBgColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *defaultTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *defaultTitleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *cancelBgColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cancelTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *cancelTitleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *destructiveBgColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveTitleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *destructiveTitleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) FLAlertButtonStyle style;
@property (nonatomic, copy) void (^handler)(FLAlertButton *button);

@property (nonatomic, assign) BOOL autoDismiss;

@property (nonatomic, assign) NSInteger index;

+ (instancetype)buttonWithTitle:(NSString *)title style:(FLAlertButtonStyle)style handler:(void (^)(FLAlertButton *button))handler;

@end
