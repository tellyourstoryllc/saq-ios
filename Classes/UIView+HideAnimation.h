//
//  UIView+HideAnimation.h
//  NoMe
//
//  Created by Jim Young on 11/22/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView(HideAnimation)

- (void)hideWithAnimation:(BOOL)animate duration:(NSTimeInterval)duration andCompletion:(void (^)())completion;
- (void)unhideWithAnimation:(BOOL)animate duration:(NSTimeInterval)duration andCompletion:(void (^)())completion;

@end
