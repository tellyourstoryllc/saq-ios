//
//  NoobCamcorder.m
//  NoMe
//
//  Created by Jim Young on 11/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "NoobCamcorder.h"
#import "BaseCamera.h"
#import "App.h"
#import "AppViewController.h"
#import "PNUserPreferences.h"
#import "AlertView.h"
#import "StatusView.h"
#import "PNCircularProgressView.h"

#import "PNImageMultiplyFilter.h"
#import "PNVerticalMirrorFilter.h"
#import "PNHorizontalMirrorFilter.h"
#import "PNKaleidoscopeFilter.h"
#import "MultiBulgeFilter.h"
#import "PNPixellateFilter.h"
#import "PNContrastLevelsColorFilter.h"

#import "ArrowBox.h"

@interface NoobCamcorder()<GraffitiDelegate> {
    SystemSoundID myStartSoundID;
    SystemSoundID myStopSoundID;
}

@property (nonatomic, assign) BOOL skipMicrophoneWarning;

@property (nonatomic, strong) PNCircularProgressView* circleProgress;

@property (nonatomic, strong) UITapGestureRecognizer* filterGesture;

@property (nonatomic, assign) BOOL isSnapping;

@property (nonatomic, assign) CGFloat savedBrightness;

// Instructional labels
@property (nonatomic, strong) PNLabel* recordLabel;
@property (nonatomic, strong) PNLabel* previewLabel;

@end

@implementation NoobCamcorder

- (NSArray*)filterList {

    // This is shitty- sort of like "importing" filters specified via strings to make sure they can be found.
    static NSArray* preloading;
    if (!preloading)
        preloading = @[
                       [GPUImageSaturationFilter class],
                       [GPUImageVignetteFilter class],
                       [GPUImageTiltShiftFilter class],
                       [GPUImageStretchDistortionFilter class],
                       [GPUImageSepiaFilter class],
                       [GPUImagePosterizeFilter class],
                       ];

    return @[
             [GPUImageCropFilter class],
             [GPUImageMonochromeFilter class],
             [GPUImageSmoothToonFilter class],

             @{@"PNCompoundImageFilter":
                   @{@"filters":
                         @[
                             @{@"GPUImageGrayscaleFilter":@{}},
                             @{@"GPUImagePosterizeFilter":@{@"colorLevels":@(1)}},
                             ]
                     }
               },
             ];
}

- (NSDictionary*)filterParams {
    return @{
             @"GPUImageSwirlFilter":@{@"angle":@(0.3)},
             @"GPUImageSepiaFilter":@{@"intensity":@(0.85)},
             @"GPUImageSketchFilter":@{@"edgeStrength":@(2.0)},
             @"GPUImageVignetteFilter":@{@"vignetteStart":@(0.2),@"vignetteEnd":@(0.65)},
             @"GPUImagePosterizeFilter":@{@"colorLevels":@(1)},
             @"GPUImageSaturationFilter":@{@"saturation":@(1.8)},
             @"GPUImageGaussianSelectiveBlurFilter":@{@"blurRadiusInPixels":@(2),@"excludeCircleRadius":@(0.3)},
             @"GPUImageTiltShiftFilter":@{@"blurRadiusInPixels":@(4),@"topFocusLevel":@(0.0),@"bottomFocusLevel":@(0.5),@"focusFallOffRate":@(0.5)},
             @"GPUImageHalftoneFilter":@{@"fractionalWidthOfAPixel":@(.025)},
             @"GPUImagePixellateFilter":@{@"fractionalWidthOfAPixel":@(.04)},
             @"GPUImagePolkaDotFilter":@{@"fractionalWidthOfAPixel":@(.03)},
             };
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.recordingPaused = YES;
    self.resumeRecordingDelay = 0.1;
    self.controlsYoverlap = -10.0;

    self.cropToSquare = NO;
    self.showFlipButton = YES;
    self.allowFilterSwipes = YES;
    self.allowModeSwipes = YES;
    self.mirrorFrontCamera = YES;
    self.filteredAudio = NO;
    self.compressVideo = NO;
    self.maxRecordingDuration = 10;
    self.pinchToZoom = YES;
    self.showCancelButton = YES;
    self.controlsYoffset = 30;
    self.verticalFilterSwipes = YES;

    self.publishButtonColor = COLOR(turquoiseColor);
//    [self.publishButton setBorderWithColor:[UIColor clearColor] width:0];
    [self.publishButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.publishButton setImage:nil forState:UIControlStateNormal];

    [self.recordButton setImage:nil forState:UIControlStateNormal];
//    [self.recordButton setBorderWithColor:[COLOR(whiteColor) colorWithAlphaComponent:0.5] width:5];

    [self.cancelButton setImage:nil forState:UIControlStateNormal];
    [self.cancelButton maskWithImage:[UIImage imageNamed:@"x"] inverted:NO];
    self.cancelButtonAlpha = 0.66;
    self.cancelButton.hidden = YES;

    [self.discardButton setImage:nil forState:UIControlStateNormal];
    [self.discardButton maskWithImage:[UIImage imageNamed:@"x"] inverted:NO];

    self.stopRecordingButton.frame = CGRectMake(0,0,60,60);
    [self.stopRecordingButton setImage:nil forState:UIControlStateNormal];
    self.stopRecordingButton.buttonColor = COLOR(turquoiseColor);

    CGRect arrowRect = CGRectMake(0, 0, 30, 40);
    ArrowBox* arrow = [[ArrowBox alloc] initWithFrame:arrowRect];
    arrow.arrowColor = [UIColor blackColor];
    arrow.rightArrowWidth = arrowRect.size.width;
    arrow.leftArrowWidth = 0;
    [self.stopRecordingButton maskWithView:arrow inverted:YES];

    self.swapCameraButton.buttonColor = [UIColor clearColor];
    [self.swapCameraButton setBorderWithColor:[UIColor clearColor] width:0];
    self.swapCameraButton.alpha = 0.8;

    self.discardButton.buttonColor =  [COLOR(darkGrayColor) colorWithAlphaComponent:0.66];

    self.playButton.buttonColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.66];
    self.playButton.highlightedColor = COLOR(orangeColor);
    self.playButton.selectedColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.3];
    self.publishButtonColor = COLOR(turquoiseColor);

    // Color of the shutter button
    self.videoCameraButtonColor = [COLOR(redColor) colorWithAlphaComponent:0.2];

    self.viewportBackgroundColor = COLOR(blackColor);

    self.progressView.progressImage = [UIImage imageWithColor:[COLOR(redColor) colorWithAlphaComponent:0.666] cornerRadius:0];

    self.circleProgress = [[PNCircularProgressView alloc] init];
    self.circleProgress.userInteractionEnabled = NO;
    self.circleProgress.lineWidth = 8;
    self.circleProgress.radiusOffset = 6;
    self.circleProgress.tintColor = [UIColor clearColor];
    self.circleProgress.progressColor = [COLOR(redColor) colorWithAlphaComponent:1.0];
    self.circleProgress.hidden = YES;
    [self.controlsView insertSubview:self.circleProgress belowSubview:self.recordButton];

    self.recordLabel = [PNLabel labelWithText:@"hold down to record" andFont:HEADFONT(18)];
    self.recordLabel.textAlignment = NSTextAlignmentCenter;
    [self.controlsView addSubview:self.recordLabel];

    self.previewLabel = [PNLabel labelWithText:@"next" andFont:HEADFONT(14)];
    self.previewLabel.textAlignment = NSTextAlignmentCenter;
    [self.controlsView addSubview:self.previewLabel];

    self.graffitiView = [[GraffitiView alloc] init];
    self.graffitiView.graffitiDelegate = self;
    self.graffitiView.hidden = YES;
    self.graffitiView.clipsToBounds = YES;
    [self addSubview:self.graffitiView];

    __weak NoobCamcorder* weakSelf = self;
    [self setRecordingProgressBlock:^(NSTimeInterval time, CGFloat progress) {
        [weakSelf.circleProgress setProgress:progress];
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle,CFSTR("camcorder-record-start"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef,&myStartSoundID);
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle,CFSTR("camcorder-record-stop"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef,&myStopSoundID);

    id quality = [Configuration settingFor:@"camera_quality"];
    self.cameraQuality = quality ? [quality integerValue] : 3;

    NSNumber* cameraPositionPref = [[PNUserPreferences shared] getPreference:@"camcorder_last_position"];
    self.cameraPosition = cameraPositionPref ? cameraPositionPref.integerValue : AVCaptureDevicePositionFront;

    NSNumber* cameraFilterIndex = [[PNUserPreferences shared] getPreference:@"camcorder_last_filter_index"] ?: @(0);
    [self activateFilterAtIndex:cameraFilterIndex.integerValue];

    [self.recordButton setImage:nil forState:UIControlStateNormal];

    self.filterGesture = [[UITapGestureRecognizer alloc] init];
    self.filterGesture.numberOfTapsRequired = 1;
    [self.filterGesture addTarget:self action:@selector(switchFilter)];
    [self.cameraView addGestureRecognizer:self.filterGesture];

    self.savedBrightness = [[UIScreen mainScreen] brightness];

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    self.cancelButton.frame = CGRectSetMiddleLeft(10, CGRectGetMidY(self.recordButton.frame), self.cancelButton.frame);
    self.discardButton.frame = self.cancelButton.frame;

    self.stopRecordingButton.frame = CGRectSetMiddleRight(b.size.width-10, CGRectGetMidY(self.recordButton.frame), self.stopRecordingButton.frame);

    self.circleProgress.frame = CGRectInset(self.recordButton.frame, -20, -20);

    self.recordLabel.frame = CGRectSetTopCenter(self.recordButton.center.x, CGRectGetMaxY(self.recordButton.frame)+4, self.recordLabel.frame);
    self.previewLabel.frame = CGRectSetTopCenter(self.stopRecordingButton.center.x, CGRectGetMaxY(self.stopRecordingButton.frame)+4, self.previewLabel.frame);

    self.graffitiView.frame = self.cameraView.frame;
}

- (CGFloat)recordButtonRadius {
    return 50;
}

- (void) switchFilter {
    [self activateFilterAtIndex:self.currentFilterIndex+1];
}

- (void) didStartRecording {
    [self didPauseRecording];
}

- (void) didPauseRecording {
    [self configureButtons];
}

- (void) didResumeRecording {
    [self configureButtons];
}

- (void) startVineRecording {
    if (self.isVineRecording) return;

    self.isVineRecording = YES;
    [self resumeRecording];

    self.recordButton.buttonColor = COLOR(redColor);
    [self.recordButton.layer removeAllAnimations];
    PNLOG(@"video_start_recording");
}

- (void) didStopRecording {

    NSLog(@"didStopRecording");

    if (self.isVineRecording) {
        self.isVineRecording = NO;
        [self hideRecordingProgress];
    }

    AudioServicesPlaySystemSound(myStopSoundID);

    self.recordPressGesture.minimumPressDuration = 0.3;
    [self configureButtons];

    [self startVideoPlayback];

    self.graffitiView.buttonOffset = CGPointMake(0, -1*self.overlayHolder.frame.origin.y);
    self.graffitiView.hidden = NO;

//    [self.graffitiView addCutout:CGRectMakeCorners(0, self.bounds.size.height-100, self.bounds.size.width, self.bounds.size.height)];
//    CGRect r = [self.graffitiView convertRect:self.discardButton.frame fromView:self.composeView];
//    [self.graffitiView addCutout:r];

}

- (void) didAbortRecording {
    [self.circleProgress setProgress:0];
    self.circleProgress.hidden = YES;
    self.recordPressGesture.minimumPressDuration = 0.3;
    self.isVineRecording = NO;
}

- (void) didFinishVideoPlayback {
    [super didFinishVideoPlayback];
    // Keep looping
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.player.currentPlaybackTime = 0.0;
        [self.player play];
    });
}

- (void) willStartPreviewing {
    self.recordButton.buttonColor = self.videoCameraButtonColor;

    self.graffitiView.hidden = YES;
    [self.graffitiView clear];
}

- (void)startPreviewWithCompletion:(void (^)(BOOL success))completion {
    void (^completionBlock)(BOOL) = ^(BOOL suc) {
        self.cameraView.hidden = NO;
        [self configureButtons];

        self.recordingPaused = YES;
        [self startRecordingWithCompletion:^(BOOL success) {
            if (completion) completion(success);
        }];
    };

    [super startPreviewWithCompletion:completionBlock];
}

//- (void)stopPreview {
//    [super stopPreview];
//    self.cameraView.hidden = YES;
//}

- (void) recordPressed:(UILongPressGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.isVineRecording) {
            self.recordLabel.text = nil;
            [self resumeRecording];
            self.recordButton.buttonColor = COLOR(redColor);
        }
        else {
            self.recordingPaused = YES;
            [self startRecordingWithCompletion:^(BOOL success) {
                [self showRecordingProgress];
                [self startVineRecording];
            }];
        }
    }
    else if (self.isVineRecording && gesture.state == UIGestureRecognizerStateEnded) {
        [self pauseRecording];
        self.recordButton.buttonColor = [COLOR(redColor) colorWithAlphaComponent:0.3];
        self.recordPressGesture.minimumPressDuration = 0.0;

        if (self.recordingDuration < 1.0)
            self.recordLabel.text = @"press to continue recording";
    }
}

- (void)recordTapped {
    //
}

- (void)swapCamera:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self swapCameraWithCompletion:nil];
    }
}

- (void) didSwipeToFilter:(GPUImageOutput<GPUImageInput> *)filter {
    PNLOG(@"switch_filter");
    [[PNUserPreferences shared] setPreference:@"camcorder_last_filter_index" object:@(self.currentFilterIndex)];
    [TutorialBubble dismissTutorialNamed:@"center_camera_swipe"];
}

- (NSUInteger) frameRate {
    return [App isCrappyDevice] ? 15 : 0;
}

- (void)didResetCamera
{
    NSError* err;
    if ([self.avCamera lockForConfiguration:&err]) {
        if ([self.avCamera isLowLightBoostSupported])
            [self.avCamera setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
        [self.avCamera unlockForConfiguration];
    }
}

- (void) microphoneEnabled:(BOOL)enabled withUserInput:(BOOL)askedUser {
    self.microphoneEnabled = enabled;

    if (enabled) return;
    if (self.skipMicrophoneWarning) return;

    [AlertView showWithTitle:@"Microphone Disabled"
                  andMessage:[NSString stringWithFormat:@"Your videos will be silent. You can enable sound by going to your device Settings > Privacy > Microphone > Turn on for %@", kAppTitle]];
    self.skipMicrophoneWarning = YES;
}

- (void) configureButtons {
    self.cancelButton.hidden = !self.isRecording || !self.recordingPaused || self.recordingDuration < 1.f;
    self.stopRecordingButton.hidden = !self.isRecording || !self.recordingPaused || self.recordingDuration < 1.f;
    self.discardButton.hidden = !self.isComposing;

    self.previewLabel.hidden = self.stopRecordingButton.hidden;
}

- (void)takeSnapshot {
    return;

    if (self.isSnapping) return;
    self.isSnapping = YES;

    [self snapIt];
    PNLOG(@"snapshot");
    //    NSString* logOrientation = [NSString stringWithFormat:@"snapshot_orientation.%d.%d", self.cameraPosition, self.currentImageOrientation];
    //    PNLOG(logOrientation);
}

- (void)snapIt {
    if (![Configuration boolFor:@"no_hd_snaps"] && ![App isCrappyDevice]) {
//        [self playShutterSound];
        [self takeHDSnapshotWithCompletion:^UIImage *(UIImage *snap) {
            self.isSnapping = NO;
            return nil;
        }];
    }
    else {
//        [self playShutterSound];
        [self takeFastSnapshotWithCompletion:^UIImage *(UIImage *snap) {
            self.isSnapping = NO;
            return nil;
        }];
    }
}


- (void) showRecordingProgress {

//    if (self.circleProgress.alpha > 0.0) return;
    self.circleProgress.hidden = NO;
//    self.circleProgress.alpha = 1.0;

    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.circleProgress.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         //
                     }];
}

- (void)hideRecordingProgress {
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.circleProgress.alpha = 0.5;
                     } completion:^(BOOL finished) {
                         [self.circleProgress setProgress:0];
                         self.circleProgress.alpha = 0.0;
                     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {}

- (void) onWillResignActive {
    self.skipMicrophoneWarning = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
