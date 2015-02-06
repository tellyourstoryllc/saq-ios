//
//  UIView+HideAnimation.m
//  NoMe
//
//  Created by Jim Young on 11/22/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "UIView+HideAnimation.h"

@implementation UIView(HideAnimation)

- (void)hideWithAnimation:(BOOL)animate duration:(NSTimeInterval)duration andCompletion:(void (^)())completion {
    self.hidden = YES;
}

- (void)unhideWithAnimation:(BOOL)animate duration:(NSTimeInterval)duration andCompletion:(void (^)())completion {
    self.hidden = NO;
}

@end
