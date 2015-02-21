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

    UIColor* navColor = COLOR(blueColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(24),
                                        NSForegroundColorAttributeName:COLOR(whiteColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(whiteColor)];

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    self.navigationItem.title = @"Help";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Resources" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.loginBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(onLogin)];
    self.navigationItem.rightBarButtonItem = self.loginBarButton;

    self.body = [[PNRichLabel alloc] initWithFrame:CGRectMake(8, 70, self.view.bounds.size.width-16, self.view.bounds.size.height-70)];
    self.body.text = @"If you are in danger, please <b><font color='#0000ff'><a href=tel:911>CALL 911</a></font></b>.<br><br>To speak to a sexual assault counselor, call <font color='#0000ff'><a href=tel:800-656-4673>800-656-4673</a></font><br><br>We need volunteers to help us screen videos.  To volunteer, email <font color='#0000ff'><a href=mailo:volunteer@tellyourstory.org>volunteer@tellyourstory.org</a></font><br><br>For technical assistance, email <font color='#0000ff'><a href=mailto:techsupport@tellyourstory.org>techsupport@tellyourstory.org</a></font>";
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
