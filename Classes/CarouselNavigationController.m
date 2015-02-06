//
//  CarouselNavigationController.m
//  NoMe
//
//  Created by Jim Young on 1/24/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "CarouselNavigationController.h"

@interface CarouselNavigationController ()

@end

@implementation CarouselNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    [self updateCarouselScrollingEnabled];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController* result = [super popViewControllerAnimated:animated];
    [self updateCarouselScrollingEnabled];
    return result;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray* result = [super popToRootViewControllerAnimated:animated];
    [self updateCarouselScrollingEnabled];
    return result;
}

- (NSArray *)popToViewController:(UIViewController *)viewController
                        animated:(BOOL)animated {
    NSArray* result = [super popToViewController:viewController animated:animated];
    [self updateCarouselScrollingEnabled];
    return result;
}

- (void)updateCarouselScrollingEnabled {
    if ([self isViewVisible]) {
        BOOL enabled = self.viewControllers.count < 2 ? YES : NO;
        self.carouselController.carousel.scrollEnabled = enabled;
    }
}

@end
