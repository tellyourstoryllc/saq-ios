//
//  PasswordSettingsCell.m
//
//
//  Created by Jim Young on 3/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PasswordSettingsCell.h"
#import "PasswordViewController.h"
#import "AlertView.h"
#import "SkyAccount.h"

@interface PasswordSettingsCell()
@property (nonatomic, strong) PNButton* button;
@end

@implementation PasswordSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [[PNButton alloc] initWithFrame:CGRectMake(0,0,140,40)];
        [self.button setTitle:@"Set Password" forState:UIControlStateNormal];
        [self.button setBorderWithColor:COLOR(darkGrayColor) width:1.0];
        self.button.buttonColor = [UIColor clearColor];
        self.button.titleLabel.font = FONT(14);
        [self.button setTitleColor:COLOR(darkGrayColor) forState:UIControlStateNormal];

        [self addChild:self.button];
        [self.button addTarget:self action:@selector(onButton) forControlEvents:UIControlEventTouchUpInside];

        self.paddingY = 10;
        [self sizeToFit];
    }
    return self;
}

- (void)onButton {
    PasswordViewController* vc = [[PasswordViewController alloc] init];
    [self.controller.navigationController pushViewController:vc animated:YES];
}

- (void)layoutSubviews {
    self.button.frame = CGRectSetTopRight(self.bounds.size.width-20, 0, self.button.frame);
    [super layoutSubviews];
}

@end
