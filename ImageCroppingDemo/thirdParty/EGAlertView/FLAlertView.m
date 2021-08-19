//
//  FLAlertView.m
//  ImageCroppingDemo
//
//  Created by mac on 2020/2/10.
//  Copyright © 2020 mac. All rights reserved.
//

#import "FLAlertView.h"
#import "Masonry.h"

@interface FLAlertView ()

@property (nonatomic, strong, readwrite) UIImageView *maskView;

@property (nonatomic, strong, readwrite) UIView *titleView;
@property (nonatomic, strong, readwrite) UIImageView *titleBgImageView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@property (nonatomic, strong, readwrite) UIView *messageView;
@property (nonatomic, strong, readwrite) UILabel *messageLabel;

@property (nonatomic, strong, readwrite) UIView *buttonsView;

@property (nonatomic, assign) CGFloat customViewHeight;

@property (nonatomic, strong, readwrite) NSMutableArray *buttons;

@end

@implementation FLAlertView

#pragma mark - 外部方法

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [[self alloc] initWithTitle:title message:message];
}

+ (instancetype)alertWithTitle:(NSString *)title
             attributedMessage:(NSAttributedString *)message {
    return [[self alloc] initWithTitle:title attributedMessage:message];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message {
    self = [super init];
    if (self) {
        [self _setup];
        
        _titleLabel.text = title;
        _messageLabel.text = message;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
            attributedMessage:(NSAttributedString *)message {
    self = [super init];
    if (self) {
        [self _setup];
        
        _titleLabel.text = title;
        _messageLabel.attributedText = message;
    }
    return self;
}

- (void)addButton:(FLAlertButton *)button {
    if (!button) {
        return;
    }
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons addObject:button];
    [self.buttonsView addSubview:button];
}

- (void)addButtonWithTitle:(NSString *)title
                     style:(FLAlertButtonStyle)style
                   handler:(void (^)(FLAlertButton *))handler {
    FLAlertButton *button = [FLAlertButton buttonWithTitle:title style:style handler:handler];
    [self addButton:button];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [self showInView:window];
}

- (void)showInView:(UIView *)view {
    [view addSubview:self.maskView];
    [view addSubview:self];
    [self layout];
    [self addSeperators];
    
    self.maskView.alpha = 0;
    self.alpha = 0;
    [UIView animateWithDuration:0.25f animations:^{
        self.maskView.alpha = 1.f;
         self.alpha = 1;
    }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.maskView.alpha = 0;
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.maskView removeFromSuperview];
                         [self removeFromSuperview];
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)setTitleBgImage:(UIImage *)titleBgImage {
    _titleBgImage = titleBgImage;
    self.titleBgImageView.image = titleBgImage;
}

- (void)setTitleBgColor:(UIColor *)titleBgColor {
    _titleBgColor = titleBgColor;
    self.titleView.backgroundColor = titleBgColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    self.messageLabel.font = messageFont;
}

- (void)setCustomView:(UIView *)view height:(CGFloat)height {
    self.customView = view;
    self.customViewHeight = height;
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [self addSubview: customView];
}

#pragma mark - 内部方法

- (void)_setup {
    _buttons = [NSMutableArray array];
    
    _titleEdgeInsets = [[[self class] appearance] titleEdgeInsets];
    if (UIEdgeInsetsEqualToEdgeInsets(_titleEdgeInsets, UIEdgeInsetsZero)) {
        _titleEdgeInsets = UIEdgeInsetsMake(24, 18, 24, 18);//UIEdgeInsetsMake(10, 10, 11, 10);
    }
    
    _messageEdgeInsets = [[[self class] appearance] messageEdgeInsets];
    if (UIEdgeInsetsEqualToEdgeInsets(_messageEdgeInsets, UIEdgeInsetsZero)) {
        _messageEdgeInsets = UIEdgeInsetsMake(0, 15, 20, 15);//UIEdgeInsetsMake(20, 15, 20, 15);
    }
    
    _alertViewWidth = [[[self class] appearance] alertViewWidth];
    if (_alertViewWidth == 0) {
        _alertViewWidth = 300;
    }
    
    _alertButtonHeight = [[[self class] appearance] alertButtonHeight];
    if (_alertButtonHeight == 0) {
        _alertButtonHeight = 44;
    }
    
//    _alertCornerRadius = [[[self class] appearance] alertCornerRadius];
//    if (_alertCornerRadius == 0) {
//        _alertCornerRadius = 10;
//    }
    _alertCornerRadius = 6.f;
    
    _separatorColor = [[[self class] appearance] separatorColor];
    if (!_separatorColor) {
        _separatorColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1];
    }
    
    _titleBgImage = [[[self class] appearance] titleBgImage];
    _titleBgColor = [[[self class] appearance] titleBgColor] ?: [UIColor clearColor];
    _titleColor = [[[self class] appearance] titleColor] ?: [UIColor blackColor];
    _titleFont = [[[self class] appearance] titleFont] ?: [UIFont boldSystemFontOfSize:16]; // 18
    
    _messageColor = [UIColor colorWithRed:87.f/255.f green:87.f/255.f blue:87.f/255.f alpha:1.f];//[[[self class] appearance] messageColor] ?: [UIColor blackColor];
    _messageFont = [[[self class] appearance] messageFont] ?: [UIFont systemFontOfSize:14]; // 16
    
    [self initViews];
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    self.layer.cornerRadius = _alertCornerRadius;
    
    _maskView = [[UIImageView alloc] init];
    _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    _maskView.userInteractionEnabled = YES;
    
    _titleView = [[UIImageView alloc] init];
    _titleView.backgroundColor = _titleBgColor;
    [self addSubview:_titleView];
    
    if (_titleBgImage) {
        _titleBgImageView = [[UIImageView alloc] initWithImage:_titleBgImage];
        [_titleView addSubview:_titleBgImageView];
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = _titleFont;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleView addSubview:_titleLabel];
    
    _messageView = [[UIImageView alloc] init];
    [self addSubview:_messageView];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.userInteractionEnabled = YES;
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = _messageFont;
    _messageLabel.textColor = _messageColor;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    [_messageView addSubview:_messageLabel];
    
    _buttonsView = [[UIView alloc] init];
    [self addSubview:_buttonsView];
}

- (UIImageView *)titleBgImageView {
    if (!_titleBgImageView) {
        _titleBgImageView = [[UIImageView alloc] init];
        [_titleView insertSubview:_titleBgImageView atIndex:0];
    }
    return _titleBgImageView;
}

- (void)layout {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(window);
    }];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.alertViewWidth));
        make.center.equalTo(window);
    }];
    
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
    }];
    
    if (_titleBgImageView) {
        [self.titleBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleView);
        }];
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (self.titleLabel.text) {
            insets = self.titleEdgeInsets;
        }
        make.edges.equalTo(self.titleView).insets(insets);
    }];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleView.mas_bottom);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (self.messageLabel.text) {
            insets = self.messageEdgeInsets;
        }
        make.edges.equalTo(self.messageView).insets(insets);
    }];
    
    UIView *buttonTopView = self.messageView;
    if (self.customView) {
        buttonTopView = self.customView;
        [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageView.mas_bottom);
            make.left.right.equalTo(self);
            if (self.customViewHeight > 0) {
                make.height.equalTo(@(self.customView.frame.size.height));
            }
        }];
    }
    
    CGFloat buttonViewHeight;
    if (self.buttons.count == 0) {
        buttonViewHeight = 0;
    } else if (self.buttons.count == 1) {
        buttonViewHeight = self.alertButtonHeight;
        UIButton *button = self.buttons.firstObject;
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.buttonsView);
        }];
    } else if (self.buttons.count == 2) {
        buttonViewHeight = self.alertButtonHeight;
        [self.buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                                  withFixedSpacing:0
                                       leadSpacing:0
                                       tailSpacing:0];
        [self.buttons mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.buttonsView);
        }];
    } else {
        buttonViewHeight = self.buttons.count * self.alertButtonHeight;
        [self.buttons mas_distributeViewsAlongAxis:MASAxisTypeVertical
                                  withFixedSpacing:0
                                       leadSpacing:0
                                       tailSpacing:0];
        [self.buttons mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.buttonsView);
        }];
    }
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(buttonViewHeight));
        make.top.equalTo(buttonTopView.mas_bottom);
    }];
}

- (void)addSeperators {
    CGFloat onePixel = [FLAlertView onePixel];
    
    for (UIButton *button in self.buttons) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = self.separatorColor;
        [button addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(button);
            make.height.equalTo(@(onePixel));
        }];
    }
    
    if (self.buttons.count == 2) {
        UIButton *button = self.buttons.firstObject;
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = self.separatorColor;
        [button addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(button);
            make.width.equalTo(@(onePixel));
        }];
    }
    //不显示中间线条
//    if (self.messageLabel.text.length) {
//        UIView *line = [[UIView alloc] init];
//        line.backgroundColor = self.separatorColor;
//        [self.titleView addSubview:line];
//        [line mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.bottom.right.equalTo(self.titleView);
//            make.height.equalTo(@(onePixel));
//        }];
//    }
}

- (void)buttonClicked:(FLAlertButton *)button {
    if (button.handler) {
        button.handler(button);
    }
    if (button.autoDismiss) {
        [self dismiss];
    }
}

+ (CGFloat)onePixel {
    UIScreen* mainScreen = [UIScreen mainScreen];
    if ([mainScreen respondsToSelector:@selector(nativeScale)]) {
        return 1.0f / mainScreen.nativeScale;
    } else {
        return 1.0f / mainScreen.scale;
    }
}

@end

@implementation FLAlertView (Add)

+ (instancetype)showWithTitle:(NSString *)title {
    return [self showWithTitle:title message:nil];
}

+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message {
    return [self showWithTitle:title
                       message:message
             cancelButtonTitle:@"我知道了"
                 okButtonTitle:nil
                       handler:nil];
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle okButtonClicked:(void (^)(void))okButtonClicked {
    
    FLAlertView *alert = [[FLAlertView alloc] initWithTitle:title message:message];
    [alert addButtonWithTitle:btnTitle
      style:FLAlertButtonStyleDefault
    handler:^(FLAlertButton *button) {
        if (okButtonClicked) {
            okButtonClicked();
        }
    }];
    
    [alert show];
    return alert;
}

+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message
                okButtonTitle:(NSString *)okButtonTitle
              okButtonClicked:(void (^)(void))okButtonClicked {
    return [self showWithTitle:title
                       message:message
             cancelButtonTitle:@"取消"
                 okButtonTitle:okButtonTitle
                       handler:^(BOOL isOkButton) {
                           if (okButtonClicked && isOkButton) {
                               okButtonClicked();
                           }
                       }];
}

+ (instancetype)showWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                okButtonTitle:(NSString *)okButtonTitle
                      handler:(void (^)(BOOL))handler {
    FLAlertView *alert = [[FLAlertView alloc] initWithTitle:title message:message];
    if (cancelButtonTitle) {
        [alert addButtonWithTitle:cancelButtonTitle
                            style:FLAlertButtonStyleCancel
                          handler:^(FLAlertButton *button) {
                              if (handler) {
                                  handler(NO);
                              }
                          }];
    }
    if (okButtonTitle) {
        [alert addButtonWithTitle:okButtonTitle
                            style:FLAlertButtonStyleDefault
                          handler:^(FLAlertButton *button) {
                              if (handler) {
                                  handler(YES);
                              }
                          }];
    }
    [alert show];
    return alert;
}

@end
