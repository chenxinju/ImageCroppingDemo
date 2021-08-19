//
//  FLAlertButton.m
//  ImageCroppingDemo
//
//  Created by mac on 2020/2/10.
//  Copyright © 2020 mac. All rights reserved.
//

#import "FLAlertButton.h"

@interface FLAlertButton ()



@end

@implementation FLAlertButton

+ (instancetype)buttonWithTitle:(NSString *)title style:(FLAlertButtonStyle)style handler:(void (^)(FLAlertButton *))handler {
    FLAlertButton *button = [FLAlertButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.style = style;
    button.handler = handler;
    return button;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _defaultBgColor = [[[self class] appearance] defaultBgColor] ?: [UIColor clearColor];
        _defaultTitleColor = [[[self class] appearance] defaultTitleColor] ?: [UIColor colorWithRed:50/255.0 green:50/255.0 blue:51/255.0 alpha:1.0];
        _defaultTitleFont = [[[self class] appearance] defaultTitleFont] ?:[UIFont systemFontOfSize:16];;
        _cancelBgColor = [[[self class] appearance] cancelBgColor] ?: [UIColor clearColor];
        _cancelTitleColor = [[[self class] appearance] cancelTitleColor] ?: [UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1.0];
        _cancelTitleFont = [[[self class] appearance] cancelTitleFont] ?: [UIFont systemFontOfSize:16];
        _destructiveBgColor = [[[self class] appearance] destructiveBgColor] ?: [UIColor clearColor];
        _destructiveTitleColor = [[[self class] appearance] destructiveTitleColor] ?: [UIColor colorWithRed:51/255.0 green:136/255.0 blue:255/255.0 alpha:1.0];
        _destructiveTitleFont = [UIFont systemFontOfSize:16];//[[[self class] appearance] destructiveTitleFont] ?: [UIFont systemFontOfSize:16];
        
        _autoDismiss = YES;
        self.style = FLAlertButtonStyleDefault;
    }
    return self;
}


- (void)setStyle:(FLAlertButtonStyle)style {
    _style = style;
    
    self.defaultTitleColor = [UIColor colorWithRed:51.f/255.f green:136.f/255.f blue:255.f/255.f alpha:1.f];
    self.destructiveTitleColor = [UIColor colorWithRed:236.f/255.f green:22.f/255.f blue:36.f/255.f alpha:1.f];
    
    switch (style) {
        case FLAlertButtonStyleDefault:
            self.backgroundColor = self.defaultBgColor;
            self.titleLabel.font = self.defaultTitleFont;
            [self setTitleColor:self.defaultTitleColor forState:UIControlStateNormal];
            break;
        case FLAlertButtonStyleCancel:
            self.backgroundColor = self.cancelBgColor;
            self.titleLabel.font = self.cancelTitleFont;
            [self setTitleColor:self.cancelTitleColor forState:UIControlStateNormal];
            break;
        case FLAlertButtonStyleDestructive:
            self.backgroundColor = self.destructiveBgColor;
            self.titleLabel.font = self.destructiveTitleFont;
            //self.destructiveTitleColor = [UIColor colorWithRed:236.f/255.f green:22.f/255.f blue:36.f/255.f alpha:1.f];
            [self setTitleColor:self.destructiveTitleColor forState:UIControlStateNormal];
            break;
    }
}

@end
