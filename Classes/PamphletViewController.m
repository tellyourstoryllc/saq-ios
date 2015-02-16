//
//  PamphletViewController.m
//  TellYourStory
//
//  Created by Jim Young on 2/13/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PamphletViewController.h"
#import "LoginController.h"
#import "App.h"

@interface PamphletViewController()

@property PNRichLabel* body;
@property (nonatomic, strong) UIBarButtonItem* loginBarButton;

@end

@implementation PamphletViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor* navColor = COLOR(lightGrayColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                        NSForegroundColorAttributeName:COLOR(blackColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(blackColor)];

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    self.navigationItem.title = @"Help";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Resources" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.loginBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(onLogin)];
    self.navigationItem.rightBarButtonItem = self.loginBarButton;

    self.body = [[PNRichLabel alloc] initWithFrame:CGRectMake(8, 70, self.view.bounds.size.width-16, self.view.bounds.size.height-70)];
    self.body.text = @"If you are in danger, please <b><a href=tel:911>CALL 911</a></b>.<br><br>To speak to a sexual assault counselor, <a href=tel:800-656-4673>call 800-656-4673</a><br><br>To donate money, send paypal to donate@thesaq.org<br><br>We need volunteers to help us screen videos.  To volunteer, <a href=mailo:volunteer@thesaq.org>email volunteer@thesaq.org</a><br><br>For technical assistance, <a href=mailto:techsupport@thesaq.org>email techsupport@thesaq.org</a>";
    self.body.textColor = COLOR(blackColor);
    self.body.font = FONT(16);
    [self.view addSubview:self.body];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem = [App isLoggedIn] ? nil : self.loginBarButton;
}

- (void)onLogin {
    [self.navigationController pushViewController:[LoginController new] animated:YES];
}

// --

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

@end
