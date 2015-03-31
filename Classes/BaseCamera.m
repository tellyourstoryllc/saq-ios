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
#import "ArrowBox.h"

@interface BaseCamera() {
    SystemSoundID myStartSoundID;
    SystemSoundID myStopSoundID;
}

@property (nonatomic, assign) BOOL skipMicrophoneWarning;
@property (nonatomic, strong) PNCircularProgressView* circleProgress;
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapGesture;
@property (nonatomic, assign) BOOL isSnapping;
@property (nonatomic, assign) CGFloat savedBrightness;
@end

@implementation BaseCamera

- (NSArray*)filterList {

    // This is shitty- sort of like "importing" filters specified via strings to make sure they can be found.
    static NSArray* preloading;
    if (!preloading)
        preloading = @[
                       [GPUImageGrayscaleFilter class],
                       [GPUImagePosterizeFilter class],
                       [GPUImagePixellateFilter class],
                       ];

    return @[
             [GPUImageCropFilter class],
             self.eyeFilter,
             [GPUImagePixellateFilter class]];
}

- (NSDictionary*)filterParams {
    return @{
             @"GPUImageSepiaFilter":@{@"intensity":@(0.85)},
             @"GPUImageSketchFilter":@{@"edgeStrength":@(2.0)},
             @"GPUImagePosterizeFilter":@{@"colorLevels":@(2)},
             @"GPUImageSaturationFilter":@{@"saturation":@(1.8)},
             @"GPUImageHalftoneFilter":@{@"fractionalWidthOfAPixel":@(.025)},
             @"GPUImagePixellateFilter":@{@"fractionalWidthOfAPixel":@(.06)},
             @"GPUImagePolkaDotFilter":@{@"fractionalWidthOfAPixel":@(.03)},
             };
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.detectFaces = YES;
    self.resumeRecordingDelay = 0.1;
    self.cropToSquare = YES;
    self.showFlipButton = NO;
    self.allowFilterSwipes = NO;
    self.allowModeSwipes = NO;
    self.mirrorFrontCamera = YES;

    self.filteredAudio = NO;

    self.cameraQuality = 0;
    self.compressVideo = NO;
    self.maxRecordingDuration = 900;
    self.pinchToZoom = NO;
    self.controlsYoffset = 0;
    self.verticalFilterSwipes = YES;
    self.minRecordingDuration = 0.5f;

    [self.publishButton setBorderWithColor:[UIColor clearColor] width:0];
    self.publishButton.buttonColor = COLOR(greenColor);

    [self.recordButton setImage:nil forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"stop-icon"] forState:UIControlStateSelected];
    self.recordButtonRadius = 40;
    self.recordButton.cornerRadius = 40;
    self.recordButton.disabledColor = COLOR(grayColor);
    self.recordButton.selectedColor = COLOR(grayColor);
    self.recordButton.enabled = NO;

    [self.cancelButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    self.cancelButton.buttonColor = [COLOR(blackColor) colorWithAlphaComponent:0.66];

    [self.discardButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];

    self.snapshotView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.composeView addSubview:self.snapshotView];
    [self.composeView sendSubviewToBack:self.snapshotView];

    self.swapCameraButton.buttonColor = [UIColor clearColor];
    [self.swapCameraButton setBorderWithColor:[UIColor clearColor] width:0];
    self.swapCameraButton.alpha = 0.8;

    self.discardButton.buttonColor =  [COLOR(blackColor) colorWithAlphaComponent:0.66];

    self.playButton.buttonColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.66];
    self.playButton.highlightedColor = COLOR(orangeColor);
    self.playButton.selectedColor = [COLOR(darkGrayColor) colorWithAlphaComponent:0.3];

    self.recordButton.buttonColor = COLOR(redColor);

    self.viewportBackgroundColor = COLOR(blackColor);

    self.progressView.progressImage = [UIImage imageWithColor:[COLOR(redColor) colorWithAlphaComponent:0.666] cornerRadius:0];

    self.circleProgress = [[PNCircularProgressView alloc] init];
    self.circleProgress.userInteractionEnabled = NO;
    self.circleProgress.lineWidth = 6;
    self.circleProgress.radiusOffset = 0;
    self.circleProgress.tintColor = [COLOR(lightGrayColor) colorWithAlphaComponent:0.5];
    self.circleProgress.progressColor = [COLOR(redColor) colorWithAlphaComponent:1.0];
    self.circleProgress.alpha = 0.0;
    [self.controlsView insertSubview:self.circleProgress belowSubview:self.recordButton];

    __weak BaseCamera* weakSelf = self;

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

    [self.recordButton setImage:nil forState:UIControlStateNormal];

    self.doubleTapGesture = [[UITapGestureRecognizer alloc] init];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.doubleTapGesture addTarget:self action:@selector(swapCamera:)];
    [self.cameraView addGestureRecognizer:self.doubleTapGesture];

    self.savedBrightness = [[UIScreen mainScreen] brightness];

    // Audio filtering
    self.audioFilter = [BaseAudioFilter new];
    [self setAudioFilteringBlock:^(AudioBuffer audioBuffer) {
        [weakSelf.audioFilter processAudioData:audioBuffer];
    }];

    self.detectFacesPeriod = -1.0; // do as fast as you can

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect b = self.bounds;

    self.circleProgress.frame = CGRectInset(self.recordButton.frame, -20, -20);

    self.snapshotView.frame = b;
    self.composeView.frame = self.cameraView.frame;
}

- (EyeMaskFilter*)eyeFilter {
    if (!_eyeFilter) {
        _eyeFilter = [EyeMaskFilter new];
        _eyeFilter.eyeSize = .25f;
        _eyeFilter.eyeFadeStartRadius = 1.f;

        __weak BaseCamera* weakSelf = self;
        [self addFaceUpdateCallback:^(NSArray* faceFeatures, CGRect clap, UIDeviceOrientation orientation) {
            [weakSelf.eyeFilter updateFace:[faceFeatures firstObject] forClap:clap andOrientation:orientation];
        }];
    }
    return _eyeFilter;
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

- (void) didStopRecording {

    [self hideRecordingProgress];

    AudioServicesPlaySystemSound(myStopSoundID);

    self.recordPressGesture.minimumPressDuration = 0.3;
    [self configureButtons];

    self.recordButton.enabled = NO;
    self.recordButton.selected = NO;

    [[AppViewController sharedAppViewController] setCarouselEnabled:YES];
}

- (void) didAbortRecording {
    [self.circleProgress setProgress:0];
    self.circleProgress.alpha = 0.0;
    self.circleProgress.hidden = YES;
    self.recordPressGesture.minimumPressDuration = 0.3;
    [self configureButtons];
    [[AppViewController sharedAppViewController] setCarouselEnabled:YES];
}

- (void) didFinishVideoPlayback {
    // Reset to beginning, but DON'T replay
    self.playButton.selected = NO;
    self.player.currentPlaybackTime = 0.0;
}

- (void) willStartPreviewing {
    self.recordButton.buttonColor = COLOR(redColor);
}

- (void)startPreviewWithCompletion:(void (^)(BOOL success))completion {
    void (^completionBlock)(BOOL) = ^(BOOL suc) {
        [self configureButtons];
        if (completion) completion(suc);
        self.recordButton.enabled = YES;
    };

    self.recordingPaused = YES;
    [super startPreviewWithCompletion:completionBlock];
}

- (void) discard {
    [super discard];
    self.snapshotView.image = nil;
}

- (void)updateForRecordingTime:(NSTimeInterval)currentSeconds {
    self.recordButton.selected = self.isRecording ? 1.0*currentSeconds > self.minRecordingDuration : NO;
}

- (void)recordPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self recordTapped];
    }
}

- (void)recordTapped {
    if (!self.isRecording) {

        [[AppViewController sharedAppViewController] setCarouselEnabled:NO];

        self.recordButton.buttonColor = COLOR(darkGrayColor);
        [self.recordButton.layer removeAllAnimations];

        [self unfilteredScreenshotWithCompletion:^(UIImage *snap) {
            self.rawScreenshot = snap;
        }];

        [self startRecordingWithCompletion:^(BOOL success) {
            [self showRecordingProgress];
            [self resumeRecording];
        }];
    }
    else {
        [self stopRecording];
    }
}

- (void)swapCamera:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self swapCameraWithCompletion:nil];
    }
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

- (CGSize)movieSize {
//    return CGSizeMake(200, 200);
    return CGSizeMake(100, 100);
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

- (void) configureButtons {
    self.discardButton.hidden = !self.isComposing;
}

- (void)takeSnapshot {
    if (self.isSnapping) return;
    self.isSnapping = YES;

        [self performSelector:@selector(snapIt) withObject:nil afterDelay:0.01];
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
}

- (UIImage*) snapshot {
    return [super snapshot];
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
//    self.circleProgress.hidden = NO;
//
//    [UIView animateWithDuration:0.2
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.circleProgress.alpha = 1.0;
//                         self.circleProgress.transform = CGAffineTransformMakeScale(1.5, 1.5);
//                     } completion:^(BOOL finished) {
//
//                         [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseIn
//                                          animations:^{
//                                              self.circleProgress.transform = CGAffineTransformMakeScale(1, 1);
//                                          }
//                                          completion:^(BOOL finished) {
//                                              self.circleProgress.transform = CGAffineTransformIdentity;
//                                          }];
//                     }];
}

- (void)hideRecordingProgress {
//    [UIView animateWithDuration:0.4
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.circleProgress.alpha = 0.5;
//                     } completion:^(BOOL finished) {
//                         [self.circleProgress setProgress:0];
//                         self.circleProgress.alpha = 0.0;
//                         self.circleProgress.hidden = YES;
//                     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {}

- (void) onWillResignActive {
    self.skipMicrophoneWarning = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
