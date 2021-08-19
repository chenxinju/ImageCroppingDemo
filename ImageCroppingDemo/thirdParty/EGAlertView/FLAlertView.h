//
//  FLAlertView.h
//  ImageCroppingDemo
//
//  Created by mac on 2020/2/10.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAlertButton.h"

@interface FLAlertView : UIView

@property (nonatomic, strong, readonly) UIImageView *maskView;

@property (nonatomic, strong, readonly) UIImageView *titleBgImageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;

@property (nonatomic, strong, readonly) NSMutableArray <FLAlertButton *> *buttons;

@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets messageEdgeInsets UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) CGFloat alertViewWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat alertButtonHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat alertCornerRadius UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImage *titleBgImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleBgColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *messageColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *messageFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIView *customView;


+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message;

+ (instancetype)alertWithTitle:(NSString *)title
             attributedMessage:(NSAttributedString *)message;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message;

- (instancetype)initWithTitle:(NSString *)title
            attributedMessage:(NSAttributedString *)message;

- (void)addButton:(FLAlertButton *)button;
- (void)addButtonWithTitle:(NSString *)title
                     style:(FLAlertButtonStyle)style
                   handler:(void (^)(FLAlertButton *button))handler;

- (void)setCustomView:(UIView *)view height:(CGFloat)height;

- (void)show;
- (void)showInView:(UIView *)view;

- (void)dismiss;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end

@interface FLAlertView (Add)


+ (instancetype)showWithTitle:(NSString *)title;


/// 快速显示一个提示（确定文本为 ‘我知道了’）
/// @param title 标题
/// @param message 内容
+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message;



/// 快速显示一个按钮提示（确定文本为 ‘外部传’）
/// @param title 标题
/// @param message 内容
/// @param btnTitle 确定按钮标题
/// @param okButtonClicked 确定事件

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle okButtonClicked:(void (^)(void))okButtonClicked;


/// 两个按钮的提示窗 默认左边为取消
/// @param title 标题
/// @param message 提示文本
/// @param okButtonTitle 右边按钮文字
/// @param okButtonClicked 右边按钮点击响应事件
+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message
                okButtonTitle:(NSString *)okButtonTitle
              okButtonClicked:(void (^)(void))okButtonClicked;


/// 双按钮的提示Alert
/// @param title 标题
/// @param message 提示文本
/// @param cancelButtonTitle 左边按钮文字
/// @param okButtonTitle 右边按钮文字
/// @param handler 按钮点击响应事件
+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                okButtonTitle:(NSString *)okButtonTitle
                      handler:(void (^)(BOOL isOkButton))handler;

@end
