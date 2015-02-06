//
//  ButtonAlertView.m
//  groups
//
//  Created by Jim Young on 12/10/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "ButtonAlertView.h"

@interface ButtonAlertView()
@property NSMutableArray* buttonArray;
@end

@implementation ButtonAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonArray = [NSMutableArray arrayWithCapacity:2];

        self.backgroundColor = COLOR(grayColor);

        self.titleLabel.textColor = COLOR(purpleColor);
        self.titleLabel.font = FONT_B(18);

        self.messageLabel.textColor = COLOR(blackColor);
        self.messageLabel.font = FONT(15);

        self.layer.cornerRadius = 10;
    }
    return self;
}

- (void)showInView:(UIView *)view {
    [super showInView:view];
    self.frame = CGRectSetBottomCenter(view.bounds.size.width/2, view.bounds.size.height, self.frame);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect b = self.bounds;
    CGFloat m = 5;
    CGFloat ml = 7;

    CGFloat maxY = MAX(MAX(CGRectGetMaxY(self.titleLabel.frame), CGRectGetMaxY(self.messageLabel.frame)), CGRectGetMaxY(self.imageView.frame));

    for (UIView* button in self.buttonArray) {
        CGFloat w = MAX(b.size.width-2*ml, button.frame.size.width);
        button.frame = CGRectMake(ml, maxY+m, w, button.frame.size.height);
        maxY = CGRectGetMaxY(button.frame);
    }
}

- (void)addButton:(UIButton *)button {
    [self.buttonArray addObject:button];
    [self addSubview:button];
}

@end
