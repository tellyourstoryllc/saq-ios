//
//  StoryMyCollectionViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MeViewController.h"

#import "User.h"
#import "Api.h"
#import "App.h"
#import "AppViewController.h"

#import "AppDelegate.h"

#import "UIImageView+AFNetworking.h"

#import "AlertView.h"
#import "StatusView.h"

#import "CalloutBubble.h"
#import "PillLabel.h"

#import "LoginController.h"
#import "MyStoryController.h"
#import "SignupController.h"

@interface MeViewController () <UINavigationControllerDelegate> {
    LoginController* _login;
    MyStoryController* _myStory;
    SignupController* _signup;
}

@property (nonatomic, strong) User* me;
@property (nonatomic, assign) BOOL completedAPIFetch;

@property (nonatomic, strong) UIBarButtonItem* loginBarButton;
@property (nonatomic, strong) UIBarButtonItem* registerBarButton;
@property (nonatomic, strong) UIBarButtonItem* cancelBarButton;
@property (nonatomic, strong) UIBarButtonItem* optionsBarButton;
@property (nonatomic, strong) UIBarButtonItem* peopleBarButton;

@end

@implementation MeViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    _login = [LoginController new];
    _login.meController = self;
    _myStory = [MyStoryController new];
    _myStory.meController = self;
    _signup = [SignupController new];
    _signup.meController = self;

    self.carousel.vertical = YES;
    self.carousel.scrollEnabled = YES;

    [self addChildViewController:_login];
    [self addChildViewController:_myStory];
    [self addChildViewController:_signup];

    self.loginBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(onLogin)];
    self.registerBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(onRegister)];
    self.cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.peopleBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"friends"]
                                                            style:UIBarButtonItemStylePlain target:self action:@selector(onPeople)];
    self.optionsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-settings-filled"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(onSettings)];
    [self setupView];
    
    [self.carousel reloadData];
    self.carousel.currentItemIndex = 1;
}

-(void)setupView {

    UIColor* navColor = COLOR(privateColor);
    UINavigationBar* navBar = self.navigationController.navigationBar;
    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];
    NSDictionary* barTextAttributes = @{NSFontAttributeName:HEADFONT(32),
                                        NSForegroundColorAttributeName:COLOR(whiteColor),
                                        NSShadowAttributeName:shadow};
    [navBar setTitleTextAttributes:barTextAttributes];
    [navBar setBarTintColor:navColor];
    [navBar setTintColor:COLOR(whiteColor)];

    [navBar setBackgroundImage:[UIImage blankImageWithSize:CGSizeMake(1, 1) color:[navColor colorWithAlphaComponent:0.88]]
                 forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];

    self.navigationItem.title = @"My Story";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Me" style:UIBarButtonItemStylePlain target:nil action:nil];

    if (!self.me) {
        self.me = [User me];
        [self.view setNeedsLayout];
    }
}

- (void)onSettings {
    [_myStory showOptions];
}

- (void)onPeople {
    [[AppViewController sharedAppViewController] openPeople];
}

- (void)onLogin {
    [self.carousel scrollToItemAtIndex:0 animated:YES];
}

- (void)onRegister {
    [self.carousel scrollToItemAtIndex:2 animated:YES];
}

- (void)onCancel {
    [self.carousel scrollToItemAtIndex:1 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isViewVisible]) {

        if (!_completedAPIFetch && [App userId]) {
            NSString *path = [NSString stringWithFormat:@"/users/%@/stories", [App userId]];
            NSMutableDictionary *params = [ @{ @"limit" : @"3" } mutableCopy];
            [[Api sharedApi] postPath:path
                           parameters:params
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 if (!error)
                                     _completedAPIFetch = YES;
                             }];
        }
    }
}

- (void)didChangeFromController:(UIViewController*)fromController
                   toController:(UIViewController*)toController
                        atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            self.navigationItem.title = @"Sign In";
            self.navigationItem.leftBarButtonItem = self.cancelBarButton;
            self.navigationItem.rightBarButtonItem = nil;

            break;

        case 1:
            self.navigationItem.title = @"My Story";
            if (self.me.registeredValue) {
                self.navigationItem.leftBarButtonItem = self.optionsBarButton;
            }
            else if (self.me.last_story) {
                self.navigationItem.leftBarButtonItem = self.registerBarButton;
            }
            else {
                self.navigationItem.leftBarButtonItem = self.loginBarButton;
            }
            self.navigationItem.rightBarButtonItem = self.peopleBarButton;
            break;

        case 2:
            self.navigationItem.title = @"Register";
            self.navigationItem.leftBarButtonItem = self.cancelBarButton;
            self.navigationItem.rightBarButtonItem = self.loginBarButton;
            break;
    }
}

- (void)openRegistration {
    [self.carousel scrollToItemAtIndex:2 animated:YES];
}

- (void)openLogin {
    [self.carousel scrollToItemAtIndex:0 animated:YES];
}

- (void)openStory {
    [self.carousel scrollToItemAtIndex:1 animated:YES];
}

// --

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.isNavigationBarHidden;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
