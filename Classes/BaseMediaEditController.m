//
//  PhotoPreviewController.m
//  groups
//
//  Created by Jim Young on 11/23/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "BaseMediaEditController.h"
#import "PNKit.h"
#import "PNUserPreferences.h"
#import "PNVideoComposer.h"
#import "DAKeyboardControl.h"

@interface BaseMediaEditController ()

@end

@implementation BaseMediaEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    self.imageView = [UIImageView new];
    // contentMode must NOT be aspect fit or aspect fill, in order for proper alignment of drawView.
    // We need to manually size the view to preserve the aspect ratio.
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:self.imageView];

    self.videoView = [VideoURLView new];
    self.videoView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:self.videoView];

    self.graffitiView = [[GraffitiView alloc] init];
    self.graffitiView.graffitiDelegate = self;
    [self.view addSubview:self.graffitiView];

    __weak BaseMediaEditController* weakSelf = self;

    [self.KVOController observe:self.graffitiView
                        keyPath:@"isTexting"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.graffitiView.isTexting ? [weakSelf didBeginTexting] : [weakSelf didEndTexting];
                          }];

    [self.KVOController observe:self.graffitiView
                        keyPath:@"isDrawing"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.graffitiView.isDrawing ? [weakSelf didBeginDrawing] : [weakSelf didEndDrawing];
                          }];

    [self.KVOController observe:self.graffitiView
                        keyPath:@"isEditing"
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              weakSelf.graffitiView.isEditing ? [weakSelf didBeginEditing] : [weakSelf didEndEditing];
                          }];

    [self.view addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        [weakSelf.view setNeedsLayout];
    }];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setPhoto:_photo];

    self.graffitiView.buttonOffset = CGPointMake(0, -1*self.imageView.frame.origin.y);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect b = self.view.bounds;
    self.videoView.frame = b;

    // Fit image view in window.
    CGSize windowSize = b.size;
    CGSize sz = _photo.size;

    if (windowSize.height && windowSize.width && sz.width && sz.height) {
        CGFloat aspectRatio = sz.width/sz.height;
        CGFloat calculatedHeight = windowSize.width/aspectRatio;
        if (calculatedHeight < windowSize.height) {
            self.imageView.frame = CGRectMake(0,0, windowSize.width, calculatedHeight);
        } else {
            CGFloat calculatedWidth = windowSize.height*aspectRatio;
            self.imageView.frame = CGRectMake(0,0, calculatedWidth, windowSize.height);
        }

        self.imageView.frame = CGRectIntegral(self.imageView.frame);
        self.imageView.frame = CGRectSetCenter(windowSize.width/2, windowSize.height/2, self.imageView.frame);

        self.graffitiView.frame = self.imageView.frame;
    }
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    [self.imageView setImage:photo];
    self.isLandscape = _photo.size.width > _photo.size.height;
    [self.view setNeedsLayout];
}

- (UIImage*)overlay {
    return self.graffitiView.overlay;
}

- (void)setOverlay:(UIImage *)overlay {
    [self.graffitiView setOverlay:overlay];
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    [self.videoView setVideoUrl:videoUrl];
    [self.videoView play];

    if (!self.photo && videoUrl) {
        __weak BaseMediaEditController* weakSelf = self;
        [PNVideoComposer fetchScreenshotForVideoUrl:videoUrl
                                             atTime:0.2
                                         completion:^(UIImage *image, Float64 actualTime) {
                                             on_main(^{
                                                 weakSelf.photo = image;
                                             });
                                         }];
    }
}

- (UIImage*)artwork {
    return self.graffitiView.artwork;
}

- (UIImage*)compositeOverlay {
    if (self.overlay && self.graffitiView.artwork)
        return [self.overlay overlayImage:self.graffitiView.artwork
                                  inFrame:CGRectMake(0,0, self.photo.size.width, self.photo.size.height)
                                blendMode:kCGBlendModeNormal
                                    alpha:1.0];
    else
        return self.graffitiView.artwork ?: self.overlay;
}

- (NSString*)caption {
    return self.graffitiView.textString;
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.isLandscape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (self.isLandscape)
        return (deviceOrientation == UIDeviceOrientationLandscapeLeft) ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
    else
        return UIInterfaceOrientationPortrait;
}

- (void)didBeginEditing {}
- (void)didEndEditing {}

- (void)didBeginDrawing {}
- (void)didEndDrawing {}

- (void)didBeginTexting {}
- (void)didEndTexting {}

- (void)dealloc {
    [_videoView stop];
    self.videoUrl = nil;
    self.photo = nil;
    self.overlay = nil;
    [self.view removeKeyboardControl];
}

@end
