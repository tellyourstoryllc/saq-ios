//
//  UIView+PostStoryAnimation.h
//  NoMe
//
//  Created by Jim Young on 1/1/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView(PostStoryAnimation)

- (void)animateStoryPostWithImage:(UIImage*)image
                          overlay:(UIImage*)overlay
                       initiation:(void (^)())initiation
                       completion:(void (^)())completion;

@end