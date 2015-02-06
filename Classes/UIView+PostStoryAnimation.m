//
//  UIView+PostStoryAnimation.m
//  NoMe
//
//  Created by Jim Young on 1/1/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "UIView+PostStoryAnimation.h"
#import "PNCircularProgressView.h"

@implementation UIView(PostStoryAnimation)

- (void)animateStoryPostWithImage:(UIImage*)image
                          overlay:(UIImage*)overlay
                       initiation:(void (^)())initiation
                       completion:(void (^)())completion
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = image;

    UIImageView* overlayImage = [[UIImageView alloc] initWithFrame:self.bounds];
    overlayImage.image = overlay;
    [imageView addSubview:overlayImage];

    __block PNCircularProgressView* progress = [[PNCircularProgressView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    progress.lineWidth = 3;
    progress.tintColor = COLOR(orangeColor);
    progress.center = self.center;
    [progress startSpinProgressBackgroundLayer];
    [imageView addSubview:progress];

    [self addSubview:imageView];

    if (initiation) initiation();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        imageView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.337
                         animations:^{
                             imageView.frame = CGRectSetBottomLeft(imageView.frame.size.width/2, 0, imageView.frame);
                             imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
                             imageView.alpha = 0.5;
                         }
                         completion:^(BOOL finished) {
                             [imageView removeFromSuperview];
                             if (completion) completion();
                         }];
    });
    
}

@end
