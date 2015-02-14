//
//  PamphletViewController.m
//  TellYourStory
//
//  Created by Jim Young on 2/13/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PamphletViewController.h"
@interface PamphletViewController()

@property PNRichLabel* body;
@property PNLabel* blurb;

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

    self.body = [[PNRichLabel alloc] initWithFrame:CGRectMake(8, 70, self.view.bounds.size.width-16, self.view.bounds.size.height-70)];
    self.body.text = @"<a href=https://www.google.com/search?q=sexual+assault&oq=sexual+assault>GOOGLE</a><br><br><a href=\"sms:8882808181\">Text</a><br><a href=\"tel:8882808181\">Call</a><br><br>";
    self.body.textColor = COLOR(blackColor);
    self.body.font = FONT(24);
    [self.view addSubview:self.body];

    self.blurb = [PNLabel labelWithText:@"(Links to help resources)" andFont:FONT_B(36)];
    self.blurb.center = self.view.center;
    self.blurb.textAlignment = NSTextAlignmentCenter;
    self.blurb.transform = CGAffineTransformMakeRotation(-M_PI/3.f);
    self.blurb.alpha = 0.3;
    [self.view addSubview:self.blurb];
}

// --

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

@end
