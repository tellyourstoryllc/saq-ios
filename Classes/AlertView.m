//
//  AlertView.m
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "AlertView.h"

@interface AlertView()
@property(nonatomic, copy) void(^afterPresent)(void);
@end

@implementation AlertView

- (void)configureAppearance {
    self.defaultButtonColor = COLOR(grayColor);
    self.defaultButtonTitleColor = COLOR(darkGrayColor);
    self.defaultButtonShadowColor = [UIColor clearColor];
    self.defaultButtonFont = FONT_B(16);
    self.defaultButtonCornerRadius = 5;
    self.defaultButtonTitleColor = COLOR(whiteColor);

    self.titleLabel.textColor = COLOR(orangeColor);
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Black" size:21];

    self.messageLabel.textColor = COLOR(blackColor);
    self.messageLabel.font = FONT(14);

    self.backgroundOverlay.backgroundColor = [COLOR(blackColor) colorWithAlphaComponent:0.888];
    self.alertContainer.backgroundColor = COLOR(lightGrayColor);
    self.alertContainer.alpha = 0.95;

    self.alertContainer.layer.cornerRadius = 5.0;
}

- (void)didPresentAlertView:(FUIAlertView *)alertView {
    if (self.afterPresent)
        self.afterPresent();
    self.afterPresent = nil;
}

- (void) showAfterPresent:(void (^)())afterPresent
           withCompletion:(void (^)(NSInteger buttonIndex))completion {
    self.afterPresent = afterPresent;
    [self showWithCompletion:completion];
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    if (self.verticalAlignment == AlertViewAlignHigh) {
        self.alertContainer.frame = CGRectSetTopCenter(b.size.width/2, 30, self.alertContainer.frame);
    }
    else if (self.verticalAlignment == AlertViewAlignLow) {
        self.alertContainer.frame = CGRectSetBottomCenter(b.size.width/2, b.size.height-30, self.alertContainer.frame);
    }
}

@end
