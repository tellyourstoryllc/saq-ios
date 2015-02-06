//
//  Camcorder.m
//  groups
//
//  Created by Jim Young on 11/15/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

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

@interface BaseCamera()<GraffitiDelegate> {
    SystemSoundID myStartSoundID;
    SystemSoundID myStopSoundID;
}

@property (nonatomic, assign) BOOL skipMicrophoneWarning;
@property (nonatomic, assign) BOOL lightingOn;

// the "flash" for the front camera
@property (nonatomic, strong) UIView* photoFlashView;
@property (nonatomic, strong) UIView* videoFlashView;
@property (nonatomic, strong) PNLabel* videoFlashLabel;

@property (nonatomic, strong) PNCircularProgressView* circleProgress;

// border that separates filters
@property (nonatomic, strong) UIView* filterSeparator;

@property (nonatomic, strong) UITapGestureRecognizer* doubleTapGesture;

@property (nonatomic, assign) BOOL isVineRecording;
@property (nonatomic, assign) BOOL isSnapping;

@property (nonatomic, assign) CGFloat savedBrightness;

@end

@implementation BaseCamera

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
                       ];

    return @[
             [GPUImageCropFilter class],

             @{@"PNCompoundImageFilter":
                   @{@"filters":
                         @[
                             @{@"GPUImageStretchDistortionFilter":@{}},
                             @{@"GPUImageSaturationFilter":@{@"saturation":@(1.8)}},
                             ]
                     }
               },

             [GPUImageSmoothToonFilter class],
             //             [GPUImagePixellateFilter class],

             [PNPixellateFilter class],
//             [GPUImagePolkaDotFilter class],

//             @{@"PNCompoundImageFilter":
//                   @{@"filters":
//                         @[
//                             @{@"GPUImagePixellateFilter":@{@"fractionalWidthOfAPixel":@(.04)}},
//                             @{@"GPUImageSaturationFilter":@{@"saturation":@(2.0)}},
//                             ]
//                     }
//               },

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
             @"GPUImagePosterizeFilter":@{@"colorLevels":@(2)},
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

    self.resumeRecordingDelay = 0.1;
    self.cropToSquare = NO;
    self.showFlipButton = YES;
    self.allowFilterSwipes = YES;
    self.allowModeSwipes = YES;
    self.mirrorFrontCamera = YES;

    self.filteredAudio = NO;

    self.compressVideo = NO;
    self.maxRecordingDuration = 30;
    self.pinchToZoom = YES;
    self.showCancelButton = YES;
    self.controlsYoffset = 0;
    self.verticalFilterSwipes = YES;
    self.minRecordingDuration = 0.5f;

    [self.publishButton setBorderWithColor:[UIColor clearColor] width:0];
    self.publishButtonColor = COLOR(greenColor);

    [self.recordButton setImage:nil forState:UIControlStateNormal];
    [self.recordButton setBorderWithColor:[COLOR(whiteColor) colorWithAlphaComponent:0.88] width:5];
    self.recordButtonRadius = 50;
    self.recordButton.cornerRadius = 50;
    self.recordButton.enabled = NO;

    [self.cancelButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    self.cancelButton.buttonColor = [COLOR(blackColor) colorWithAlphaComponent:0.66];

    [self.discardButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];

    self.stopRecordingButton.frame = CGRectMake(0,0,60,60);
    [self.stopRecordingButton setImage:nil forState:UIControlStateNormal];
    self.stopRecordingButton.buttonColor = COLOR(greenColor);
    self.stopRecordingButton.alpha = 0.8;

    self.importButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
    self.importButton.cornerRadius = 0;
    self.importButton.alpha = 0.66;
    self.importButton.buttonColor = COLOR(whiteColor);
//    [self.importButton setBorderWithColor:[COLOR(blackColor) colorWithAlphaComponent:0.33f] width:1.0];
    [self.importButton maskWithImage:[UIImage imageNamed:@"download"] inverted:YES];
    [self.cameraView addSubview:self.importButton];

    self.flashlightButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
    self.flashlightButton.cornerRadius = 25;
    self.flashlightButton.alpha = 0.6;
    self.flashlightButton.buttonColor = [UIColor clearColor];
    [self.flashlightButton addTarget:self action:@selector(toggleLighting) forControlEvents:UIControlEventTouchDown];
    [self.cameraView addSubview:self.flashlightButton];

    self.filterSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    self.filterSeparator.backgroundColor = COLOR(purpleColor);
    [self.cameraView addSubview:self.filterSeparator];

    self.snapshotView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.composeView addSubview:self.snapshotView];
    [self.composeView sendSubviewToBack:self.snapshotView];

    self.graffitiView = [[GraffitiView alloc] init];
    self.graffitiView.graffitiDelegate = self;
    self.graffitiView.hidden = YES;
    [self addSubview:self.graffitiView];

    // KVO
    [self.graffitiView addObserver:self forKeyPath:@"isTexting" options:NSKeyValueObservingOptionNew context:nil];
    [self.graffitiView addObserver:self forKeyPath:@"isDrawing" options:NSKeyValueObservingOptionNew context:nil];

    self.swapCameraButton.buttonColor = [UIColor clearColor];
    [self.swapCameraButton setBorderWithColor:[UIColor clearColor] width:0];
    self.swapCameraButton.alpha = 0.8;

    self.discardButton.buttonColor =  [COLOR(blackColor) colorWithAlphaComponent:0.66];

    self.playButton.buttonColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.66];
    self.playButton.highlightedColor = COLOR(orangeColor);
    self.playButton.selectedColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.3];

    // Color of the shutter button
    self.videoCameraButtonColor = [COLOR(redColor) colorWithAlphaComponent:0.2];

    self.viewportBackgroundColor = COLOR(blackColor);

    self.progressView.progressImage = [UIImage imageWithColor:[COLOR(redColor) colorWithAlphaComponent:0.666] cornerRadius:0];

    self.circleProgress = [[PNCircularProgressView alloc] init];
    self.circleProgress.userInteractionEnabled = NO;
    self.circleProgress.lineWidth = 8;
    self.circleProgress.radiusOffset = 6;
    self.circleProgress.tintColor = [COLOR(redColor) colorWithAlphaComponent:0.6];
    self.circleProgress.progressColor = [COLOR(redColor) colorWithAlphaComponent:1.0];
    self.circleProgress.alpha = 0.0;
    [self.controlsView insertSubview:self.circleProgress belowSubview:self.recordButton];

    __weak BaseCamera* weakSelf = self;
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

//    NSNumber* cameraFilterIndex = [[PNUserPreferences shared] getPreference:@"camcorder_last_filter_index"] ?: @(0);
//    [self activateFilterAtIndex:cameraFilterIndex.integerValue];

    self.photoFlashView = [[UIView alloc] init];
    self.photoFlashView.hidden = YES;
    [self addSubview:self.photoFlashView];

    self.videoFlashView = [[UIView alloc] init];
    self.videoFlashView.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"yellow-flash"]] colorWithAlphaComponent:0.888];
    self.videoFlashView.hidden = YES;

    self.videoFlashLabel = [PNLabel labelWithText:@"Set screen to max brightness" andFont:FONT_B(21)];
    self.videoFlashLabel.textAlignment = NSTextAlignmentCenter;
    [self.videoFlashView addSubview:self.videoFlashLabel];

    [self addSubview:self.videoFlashView];

    [self.recordButton setImage:nil forState:UIControlStateNormal];

    CGRect arrowRect = CGRectMake(0, 0, self.stopRecordingButton.bounds.size.width*0.7, self.stopRecordingButton.bounds.size.height);
    ArrowBox* playArrow = [[ArrowBox alloc] initWithFrame:arrowRect];
    playArrow.arrowColor = [UIColor blackColor];
    playArrow.rightArrowWidth = arrowRect.size.width;
    [self.stopRecordingButton maskWithView:playArrow];

    self.doubleTapGesture = [[UITapGestureRecognizer alloc] init];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.doubleTapGesture addTarget:self action:@selector(swapCamera:)];
    [self.cameraView addGestureRecognizer:self.doubleTapGesture];

    self.savedBrightness = [[UIScreen mainScreen] brightness];

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;
    self.cancelButton.frame = CGRectSetMiddleLeft(10, CGRectGetMidY(self.recordButton.frame), self.cancelButton.frame);
    self.discardButton.frame = CGRectSetOrigin(10, 10, self.discardButton.frame);

    self.stopRecordingButton.frame = CGRectSetMiddleRight(b.size.width-10, CGRectGetMidY(self.recordButton.frame), self.stopRecordingButton.frame);

    self.circleProgress.frame = CGRectInset(self.recordButton.frame, -20, -20);


    self.flashlightButton.frame = CGRectSetMiddleLeft(self.viewportInCameraView.origin.x+4,
                                                      CGRectGetMidY(self.swapCameraButton.frame),
                                                      self.flashlightButton.frame);

    self.importButton.frame = CGRectSetTopCenter(b.size.width/2, 0, self.importButton.frame);

    self.videoFlashView.frame = CGRectMakeCorners(0, 0, b.size.width, b.size.height/5);
    self.videoFlashLabel.frame = self.videoFlashView.bounds;
    self.photoFlashView.frame = b;
    self.snapshotView.frame = b;

    self.composeView.frame = self.cameraView.frame;
}

- (void) didStartRecording {
    [self didPauseRecording];
}

- (void) didPauseRecording {
    [self setLightingOn:self.lightingOn];
    [self configureButtons];
}

- (void) didResumeRecording {
    [self setLightingOn:self.lightingOn];
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

    if (self.isVineRecording) {
        self.isVineRecording = NO;
        [self hideRecordingProgress];
    }

    AudioServicesPlaySystemSound(myStopSoundID);
    self.graffitiView.frame = self.bounds;
    self.graffitiView.buttonOffset = CGPointMake(0, -1*self.overlayHolder.frame.origin.y);
    self.graffitiView.hidden = NO;

    self.recordPressGesture.minimumPressDuration = 0.3;
    [self configureButtons];

    [self.graffitiView addCutout:CGRectMakeCorners(0, self.bounds.size.height-100, self.bounds.size.width, self.bounds.size.height)];
    CGRect r = [self.graffitiView convertRect:self.discardButton.frame fromView:self.composeView];
    [self.graffitiView addCutout:r];
    [self configureButtons];

    self.recordButton.enabled = NO;
}

- (void) didAbortRecording {
    [self.circleProgress setProgress:0];
    self.circleProgress.alpha = 0.0;
    self.circleProgress.hidden = YES;
    self.recordPressGesture.minimumPressDuration = 0.3;
    self.isVineRecording = NO;
    [self configureButtons];
}

- (void) didFinishVideoPlayback {
    [super didFinishVideoPlayback];
    // Keep looping
    self.player.currentPlaybackTime = 0.0;
    [self.player play];
}

- (void) willStartPreviewing {
    self.graffitiView.hidden = YES;
    [self.graffitiView clear];
    self.recordButton.buttonColor = self.videoCameraButtonColor;

    [self setLightingOn:self.lightingOn];

}

- (void)startPreviewWithCompletion:(void (^)(BOOL success))completion {
    void (^completionBlock)(BOOL) = ^(BOOL suc) {
        [self configureButtons];
        [self startRecordingWithCompletion:^(BOOL success) {
            if (completion) completion(success);
            self.recordButton.enabled = YES;
        }];
    };

    self.recordingPaused = YES;
    [super startPreviewWithCompletion:completionBlock];
}

- (void) discard {
    [super discard];
    self.snapshotView.image = nil;
}

- (void) recordPressed:(UILongPressGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.isVineRecording) {
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
    }
}

- (void)updateForRecordingTime:(NSTimeInterval)currentSeconds {
    self.stopRecordingButton.hidden = currentSeconds == 0.0 || (1.0*currentSeconds < self.minRecordingDuration);
}

- (void)recordTapped {
    if (!self.isVineRecording) {
        [self takeSnapshot];
    }
}

- (void)swapCamera:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self swapCameraWithCompletion:nil];
    }
}

- (CGRect)swipeAreaFrame:(CGRect)viewport {
    return CGRectMakeCorners(0, CGRectGetMaxY(self.flashlightButton.frame), viewport.size.width, viewport.size.height-60);
}

- (void) didSwipeToFilter:(GPUImageOutput<GPUImageInput> *)filter {
    PNLOG(@"switch_filter");
    [[PNUserPreferences shared] setPreference:@"camcorder_last_filter_index" object:@(self.currentFilterIndex)];
}

- (NSUInteger) frameRate {
    return [App isCrappyDevice] ? 15 : 0;
}

- (UIImageOrientation)snapshotOrientation {
    return UIImageOrientationUp;
}

- (CGAffineTransform)videoRecordingOrientation {
    return CGAffineTransformIdentity;
}

- (CGAffineTransform)videoPlaybackOrientation {
    return CGAffineTransformIdentity;
}

- (void)didResetCamera
{
//    NSError* err;
//    if ([self.avCamera lockForConfiguration:&err]) {
//        if ([self.avCamera isLowLightBoostSupported])
//            [self.avCamera setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
//        [self.avCamera unlockForConfiguration];
//    }
}

- (void) setCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    [super setCameraPosition:cameraPosition];
    [[PNUserPreferences shared] setPreference:@"camcorder_last_position" object:@(self.cameraPosition)];
}

- (void) microphoneEnabled:(BOOL)enabled withUserInput:(BOOL)askedUser {
    self.microphoneEnabled = enabled;

    if (enabled) return;
    if (self.skipMicrophoneWarning) return;

    [AlertView showWithTitle:@"Microphone Disabled"
                  andMessage:[NSString stringWithFormat:@"Your videos will be silent. You can enable sound by going to your device Settings > Privacy > Microphone > Turn on for %@", kAppTitle]];
    self.skipMicrophoneWarning = YES;
}

- (void) graffitiDidStartEditing:(GraffitiView*)graffitiController {
    self.publishButton.hidden = YES;
    self.discardButton.hidden = YES;
}

- (void) graffitiDidEndEditing:(GraffitiView*)graffitiController {
    self.publishButton.hidden = NO;
    self.discardButton.hidden = NO;
}

- (void) configureButtons {

    self.importButton.hidden = self.isComposing || self.isVineRecording;

//    self.stopRecordingButton.hidden = !self.isRecording || !self.recordingPaused;

    self.flashlightButton.hidden = self.isComposing;
    self.swapCameraButton.hidden = self.isComposing;

    self.discardButton.hidden = !self.isComposing;
}

- (void)toggleLighting {
    [self setLightingOn:!self.lightingOn];
}

- (void)setLightingOn:(BOOL)onOff {
    AVCaptureDevice *device = self.avCamera;
    UIImage* image = onOff ? [UIImage imageNamed:@"flash-on"] : [UIImage imageNamed:@"flash-off"];
    [self.flashlightButton setImage:image forState:UIControlStateNormal];
    self.flashlightButton.buttonColor = onOff ? COLOR(yellowColor) : [UIColor clearColor];
    _lightingOn = onOff;

    if ([device hasTorch]) {

        if ([device lockForConfiguration:nil]) {
            if ([device isLowLightBoostSupported])
                [device setAutomaticallyEnablesLowLightBoostWhenAvailable:_lightingOn];
            [device unlockForConfiguration];
        }

        if (_lightingOn && self.isRecording && self.cameraPosition == AVCaptureDevicePositionBack) {
            if ([device hasTorch]) {
                [device lockForConfiguration:nil];
                self.recordingPaused ? [device setTorchMode:AVCaptureTorchModeOff] : [device setTorchModeOnWithLevel:0.01 error:nil];
                [device unlockForConfiguration];
            }
        }
        else {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}

- (void)takeSnapshot {
    if (self.isSnapping) return;
    self.isSnapping = YES;

    if (self.lightingOn) {
        AVCaptureDevice *device = self.avCamera;
        if (self.cameraPosition == AVCaptureDevicePositionBack) {
            if ([device hasTorch]) {
                [device lockForConfiguration:nil];
                [device setTorchModeOnWithLevel:0.01 error:nil];
                [device unlockForConfiguration];
                [self performSelector:@selector(flashPresnap) withObject:nil afterDelay:0.1];
                return;
            }
        }
        else {
            self.photoFlashView.hidden = NO;
            self.photoFlashView.backgroundColor = [COLOR(whiteColor) colorWithAlphaComponent:0.888];
            self.savedBrightness = [[UIScreen mainScreen] brightness];
            [[UIScreen mainScreen] setBrightness:1.0];
            [self performSelector:@selector(snapIt) withObject:nil afterDelay:0.2];
            return;
        }
    }
    else {
        self.photoFlashView.hidden = NO;
        self.photoFlashView.backgroundColor = COLOR(blackColor);
        [self performSelector:@selector(snapIt) withObject:nil afterDelay:0.01];
    }

    //    NSString* logOrientation = [NSString stringWithFormat:@"snapshot_orientation.%d.%d", self.cameraPosition, self.currentImageOrientation];
    //    PNLOG(logOrientation);
}

- (void)flashPresnap {
    if (self.cameraPosition == AVCaptureDevicePositionBack) {
        AVCaptureDevice *device = self.avCamera;
        [device lockForConfiguration:nil];
        [device setTorchModeOnWithLevel:AVCaptureMaxAvailableTorchLevel error:nil];
        [device unlockForConfiguration];
    }
    [self performSelector:@selector(snapIt) withObject:nil afterDelay:0.1];
}

- (void)snapIt {

    void (^presentGraffitiBlock)() = ^() {
        self.isComposing = YES;

        self.graffitiView.frame = self.bounds;
        self.graffitiView.buttonOffset = CGPointMake(0, -1*self.overlayHolder.frame.origin.y);
        self.graffitiView.hidden = NO;

        self.recordPressGesture.minimumPressDuration = 0.3;

        [self.graffitiView addCutout:CGRectMake(0, self.bounds.size.height-100, self.bounds.size.width, 80)];
        CGRect r = [self.graffitiView convertRect:self.discardButton.frame fromView:self.composeView];
        [self.graffitiView addCutout:r];

        [self configureButtons];
    };

    void (^flashBlock)() = ^() {
        AVCaptureDevice *device = self.avCamera;
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        self.photoFlashView.hidden = YES;
        [[UIScreen mainScreen] setBrightness:self.savedBrightness];
    };

    void (^noFlashBlock)() = ^() {
        self.photoFlashView.hidden = YES;
    };

    if (![Configuration boolFor:@"no_hd_snaps"] && ![App isCrappyDevice]) {
        [self playShutterSound];
        [self takeHDSnapshotWithCompletion:^UIImage *(UIImage *snap) {
            if (self.lightingOn)
                flashBlock();
            else
                noFlashBlock();

            self.isSnapping = NO;
            self.snapshotView.transform = [self videoPlaybackOrientation];
            self.snapshotView.image = snap;
            [self abortRecording];
            presentGraffitiBlock();
            return snap;
        }];
    }
    else {
        [self playShutterSound];
        [self takeFastSnapshotWithCompletion:^UIImage *(UIImage *snap) {
            NSLog(@"orintt: %d", snap.imageOrientation);
            if (self.lightingOn)
                flashBlock();
            else
                noFlashBlock();

            self.isSnapping = NO;
            self.snapshotView.transform = [self videoPlaybackOrientation];
            self.snapshotView.image = snap;
            [self abortRecording];
            presentGraffitiBlock();
            return snap;
        }];
    }
}

- (UIImage*) snapshot {
    return [super snapshot];
}

- (UIImage*) overlay {
    UIImage* image = self.graffitiView.artwork;
    return image;
}

- (NSString*) caption {
    return self.graffitiView.textString;
}

// Scales and crops image to match aspect ratio of frame
// Does nothing if image is huge, since we might run out of memory!
- (UIImage*) scaleImageToFillView:(UIImage*)image {

    CGSize screensize = self.cameraView.frame.size;

    if (screensize.width < 1500 && screensize.height < 1500) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            screensize = CGSizeMake(screensize.height, screensize.width);
        }
        CGSize newSize = [UIImage sizeOfScalingSize:screensize toSize:image.size];
        return [image imageByScalingAspectFillToSize:newSize];
    }
    else {
        return self.snapshot;
    }
}

- (void) showRecordingProgress {
    self.circleProgress.hidden = NO;

    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.circleProgress.alpha = 1.0;
                         self.circleProgress.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     } completion:^(BOOL finished) {

                         [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.circleProgress.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:^(BOOL finished) {
                                              self.circleProgress.transform = CGAffineTransformIdentity;
                                          }];
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
                         self.circleProgress.hidden = YES;
                     }];
}

- (void)drawFilterSeparatorAtPoint:(CGPoint)point {
    if (CGPointEqualToPoint(point, CGPointZero)) {
        self.filterSeparator.frame = CGRectZero;
    }
    else {
        CGFloat y = point.y > 0 ? point.y : self.frame.size.height + point.y;
        self.filterSeparator.frame = CGRectMake(0, y, self.frame.size.width, 4);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {}

- (void) onWillResignActive {
    self.skipMicrophoneWarning = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.graffitiView removeObserver:self forKeyPath:@"isTexting"];
    [self.graffitiView removeObserver:self forKeyPath:@"isDrawing"];
    NSLog(@"dealloc camcorder %@", self);
}

@end
