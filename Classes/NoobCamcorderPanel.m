//
//  NoobCamcorderPanel.m
//  NoMe
//
//  Created by Jim Young on 11/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "NoobCamcorderPanel.h"
#import "PNInsetLabel.h"
#import "LocationManager.h"
#import "PNGeocoder.h"
#import "BaseCamera.h"
#import "UILabel+FadeEffect.h"
#import "NoobCamcorder.h"
#import "Api.h"

@interface NoobCamcorderPanel ()<RTLabelDelegate, UITextFieldDelegate, PNCameraDelegate>

@property (strong) AFHTTPRequestOperation* networkOperation;

@property (strong) PNLabel *label1;
@property (strong) PNLabel *label2;
@property (strong) PNLabel *label3;
@property (strong) PNLabel *label4;

@property (strong) NoobCamcorder* recorder;
@property (nonatomic, strong) PNButton* cameraButton;

@end

@implementation NoobCamcorderPanel

- (void)didAppear {

    if (!self.recorder) {
        self.recorder = [[NoobCamcorder alloc] init];
        self.recorder.delegate = self;
        self.recorder.player.backgroundColor = COLOR(blackColor);
        [self.recorder addObserver:self forKeyPath:@"isComposing" options:NSKeyValueObservingOptionNew context:nil];
        [self.recorder addObserver:self forKeyPath:@"isVineRecording" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:self.recorder];
    }

    if (!self.recorder.isPreviewing) {
        self.recorder.alpha = 0.0;
        self.cameraButton.alpha = 1.0;
    }

    self.label1.text = @"create your first story";
    self.label2.text = @"say hello!";
    self.label3.text = @"record up to 30 seconds - press NEXT when finished";
    self.label4.text = @"you can draw and type on any story - try it";

    [self.label2 makeInvisible];
    [self.label3 makeInvisible];
    [self.label4 makeInvisible];

    self.cameraButton.hidden = NO;
//    [self.label1 makeInvisible];
//    [self.label1 fadeInOverDuration:1.0 toColor:COLOR(grayColor) completion:^{
//    }];

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [self.cameraButton setTitle:@"Tap to activate camera" forState:UIControlStateNormal];
    }
    else {
        [self.cameraButton setTitle:@"Tap to allow Access to \nMic & Camera ❭" forState:UIControlStateNormal];
    }

}

- (void)didDisappear {
    [self.recorder abortRecording];
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        self.cameraButton = [[PNButton alloc] initWithFrame:CGRectZero];
        self.cameraButton.buttonColor = COLOR(turquoiseColor);
        self.cameraButton.hidden = YES;
        [self.cameraButton addTarget:self action:@selector(onOpenCamera) forControlEvents:UIControlEventTouchDown];
        self.cameraButton.titleLabel.numberOfLines = 0;
        self.cameraButton.titleLabel.font = FONT_B(16);
        [self addSubview:self.cameraButton];

        self.label1 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label1.font = self.headerFont;
        self.label1.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label1];

        self.label2 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label2.font = self.headerFont;
        self.label2.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label2];

        self.label3 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label3.font = self.headerFont;
        self.label3.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label3];

        self.label4 = [[PNLabel alloc] initWithFrame:CGRectZero];
        self.label4.font = self.headerFont;
        self.label4.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label4];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect f = self.bounds;
    CGFloat m = 2;
    CGFloat ml = 8;

    self.cameraButton.frame = CGRectMake(0,0, f.size.width*0.66, f.size.width*0.66*1.337);
    self.cameraButton.center = self.center;

    self.label1.frame = CGRectInset(CGRectMake(0,
                                               0,
                                               f.size.width,
                                               100), ml, ml);

    self.label2.frame = self.label1.frame;
    self.label3.frame = self.label1.frame;
    self.label4.frame = self.label1.frame;

    self.recorder.frame = CGRectIntersection(CGRectInset(self.bounds, 5, 5),
                                             CGRectMake(0, CGRectGetMinY(self.cameraButton.frame), f.size.width, CGFLOAT_MAX));
    self.recorder.viewportWidth = self.cameraButton.frame.size.width;
    self.recorder.viewportHeight = self.cameraButton.frame.size.height;

}

- (void)camera:(PNCamera *)camera
publishedImage:(UIImage *)image
      andVideo:(NSURL *)videoUrl
    withParams:(NSDictionary *)params {

    [self.controller setValue:videoUrl forKey:@"videoFileURL"];
    [self.controller setValue:self.recorder.graffitiView.artwork forKey:@"videoOverlay"];

    [self gotoNextPanel];
}

- (void)onOpenCamera {

    [self.cameraButton setTitle:nil forState:UIControlStateNormal];
    self.recorder.alpha = 0.0;

    [UIView animateWithDuration:1.337 animations:^{
        self.cameraButton.alpha = 0.0;
        self.recorder.alpha = 1.0;
    }];

    [self.label1 fadeOutOverDuration:1.0 fromColor:nil completion:nil afterDelay:0];

    [self.recorder startPreviewWithCompletion:^(BOOL success) {
        self.cameraButton.hidden = YES;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    on_main(^{
        if (self.recorder.isComposing) {
            [self.label2 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                [self.label3 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                    [self.label4 fadeInOverDuration:1.0 toColor:COLOR(darkGrayColor) completion:^{
                    }];
                } afterDelay:0];
            }];
        }
        else if (self.recorder.isVineRecording) {
            [self.label2 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                [self.label4 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                    [self.label3 fadeInOverDuration:1.0 toColor:COLOR(darkGrayColor) completion:nil];
                } afterDelay:0];
            }];
        }
        else if (self.recorder.isPreviewing || self.recorder.isRecording) {
            [self.label4 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                [self.label3 fadeOutOverDuration:1.0 fromColor:nil completion:^{
                    [self.label2 fadeInOverDuration:1.0 toColor:COLOR(darkGrayColor) completion:nil];
                } afterDelay:0];
            }];
        }
    });
}

- (void)dealloc {
    [self.recorder removeObserver:self forKeyPath:@"isComposing"];
}

@end
