//
//  LogoutSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "LogoutSettingsCell.h"
#import "App.h"
#import "PNUIAlertView.h"
#import "SkyAccount.h"
#import "PasswordViewController.h"

@interface LogoutSettingsCell()
@property (nonatomic, strong) PNButton* logoutButton;
@end

@implementation LogoutSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.logoutButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,80,40)];
        [self.logoutButton setTitle:@"Sign out" forState:UIControlStateNormal];
        [self.logoutButton setBorderWithColor:COLOR(darkGrayColor) width:1.0];
        self.logoutButton.buttonColor = [UIColor clearColor];
        self.logoutButton.titleLabel.font = FONT(14);
        [self.logoutButton setTitleColor:COLOR(darkGrayColor) forState:UIControlStateNormal];

        [self addChild:self.logoutButton];
        [self.logoutButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];

        self.paddingY = 20;
        [self sizeToFit];
    }
    return self;
}

- (void)logoutTapped {
    if (![[SkyAccount mine] needs_passwordValue]) {
        PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:@"Sign out?" message:nil andButtonArray:@[@"No", @"Yes"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [self.controller dismissViewControllerAnimated:YES completion:^{
                    [App logout];
                }];
            }
        }];
    }
    else {
        PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:@"Password needed"
                                                            message:@"Please set a password so you can login later or from another device."
                                                     andButtonArray:@[@"Set password", @"Not now"]];
        [alert showWithCompletion:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                PasswordViewController* vc = [[PasswordViewController alloc] init];
                [self.controller.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

- (void)layoutSubviews {
    self.logoutButton.frame = CGRectSetTopRight(self.bounds.size.width-20, 0, self.logoutButton.frame);
    [super layoutSubviews];
}

@end
