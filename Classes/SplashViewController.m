//
//  SplashViewController.m
//  groups
//
//  Created by Jim Young on 1/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "SplashViewController.h"
#import "AFNetworking.h"

@interface SplashViewController()
@property (nonatomic, strong) PNLabel* infoLabel;
@end

@implementation SplashViewController

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(defaultBackgroundColor);

    self.infoLabel = [[PNLabel alloc] initWithFrame:CGRectZero];
    self.infoLabel.font = HEADFONT(32);
    self.infoLabel.textColor = COLOR(redColor);
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.infoLabel];

    [[AFNetworkReachabilityManager sharedManager] addObserver:self forKeyPath:@"reachable" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewWillLayoutSubviews {
    self.infoLabel.frame = CGRectInset(self.view.bounds,20,20);
}

- (void)updateText {
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        self.infoLabel.text = nil;
    }
    else {
        self.infoLabel.text = [NSString stringWithFormat:@"unable to initialize service. please check your device's internet connection."];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateText];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateText];
    [self.view setNeedsLayout];
}

- (void) dealloc {
    [[AFNetworkReachabilityManager sharedManager] removeObserver:self forKeyPath:@"reachable"];
}

@end
