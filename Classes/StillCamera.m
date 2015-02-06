//
//  StillCamera.m
//  groups
//
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "StillCamera.h"
#import "PNImageMultiplyFilter.h"
#import "PNVerticalMirrorFilter.h"
#import "PNHorizontalMirrorFilter.h"
#import "PNKaleidoscopeFilter.h"
#import "PNUserPreferences.h"

#import "PN1972Filter.h"
#import "PNBrannanFilter.h"
#import "PNToastFilter.h"

@interface StillCamera()
@property (nonatomic, assign) BOOL skipMicrophoneWarning;

@end

@implementation StillCamera

- (NSArray*)filterList {
    return @[
             [GPUImageGrayscaleFilter class],
             [PN1972Filter class],
             [PNBrannanFilter class],
             ];
}

- (NSDictionary*)filterParams {
    return @{};
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.cropToSquare = YES;
    self.showFlipButton = YES;
    self.allowFilterSwipes = YES;
    self.filteredAudio = NO;
    self.compressVideo = NO;
    self.maxRecordingDuration = 30;

    NSNumber* cameraPositionPref = [[PNUserPreferences shared] getPreference:@"still_camera_last_position"];
    self.cameraPosition = cameraPositionPref ? cameraPositionPref.integerValue : AVCaptureDevicePositionBack;

    [self.recordButton setImage:[UIImage imageNamed:@"input-photo"] forState:UIControlStateNormal];
    [self.publishButton setImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];

    //  self.swapCameraButton.buttonColor = [[Theme current] grayColor];
    //  [self.swapCameraButton setBorderWithColor:[[Theme current] whiteColor] width:1.0];
    //
    //  self.screenshotButton.buttonColor = [[Theme current] grayColor];
    //  [self.screenshotButton setBorderWithColor:[[Theme current] whiteColor] width:1.0];
    //
    //  self.errorLabel.font = [[Theme current] boldFontWithSize:24];
    //  self.errorLabel.textColor = [[Theme current] redColor];
    //  self.errorLabel.shadowColor = [[Theme current] whiteColor];
    //
    //  self.cancelButton.buttonColor = [[Theme current] darkGrayColor];
    //  [self.cancelButton setBorderWithColor:[[Theme current]whiteColor] width:2.0];
    //
    //  self.discardButton.buttonColor = [[Theme current] darkGrayColor];
    //  [self.discardButton setBorderWithColor:[[Theme current]whiteColor] width:2.0];
    //
    //  [self.recordButton setBorderWithColor:[[Theme current] whiteColor] width:2.0];
    //
    //  self.playButton.buttonColor = [[Theme current] grayColor];
    //  self.playButton.highlightedColor = [[Theme current] greenColor];
    //  self.playButton.selectedColor = [[Theme current] grayColor];
    //  [self.playButton setBorderWithColor:[[Theme current]whiteColor] width:2.0];
    //
    //  self.captionTextField.font = [[Theme current] fontWithSize:16];
    //  self.captionTextField.textColor = [[Theme current] whiteColor];
    //  self.captionTextField.backgroundColor = [[Theme current] blackColor];
    //  self.captionTextField.placeholder = @"Description or #tags";
    //
    //  self.publishButton.backgroundColor = [[Theme current] greenColor];
    //  [self.publishButton setBorderWithColor:[[Theme current] whiteColor] width:2.0];
    //
    //  self.stillCameraButtonColor = [[Theme current] grayColor];
    //  self.videoCameraButtonColor = [[Theme current] redColor];
    //  self.stopButtonColor = [[Theme current] blackColor];
    //  self.normalTimerLabelColor = [[Theme current] whiteColor];
    //  self.publishButtonColor = [[Theme current] greenColor];
    //
    //  self.viewportBackgroundColor = [[Theme current] whiteColor];
    //
    //  self.progressView.progressImage = [UIImage imageWithColor:[[[Theme current] orangeColor] colorWithAlphaComponent:0.666] cornerRadius:0];
    //


    self.publishButtonColor = COLOR(greenColor);

    self.cameraRollButton = [[PNButton alloc] init];
    self.cameraRollButton.buttonColor = COLOR(darkGrayColor);
    self.cameraRollButton.cornerRadius = self.playButton.cornerRadius;
    [self.cameraRollButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];

    [self.controlsView addSubview:self.cameraRollButton];

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.cameraRollButton.frame = self.playButton.frame;
}

- (CGFloat) controlsYoverlap {
    return self.cropToSquare ? 0 : 100;
}

- (void)didResetCamera
{
    NSError* err;
    if ([self.avCamera lockForConfiguration:&err]) {
        if ([self.avCamera isLowLightBoostSupported])
            [self.avCamera setAutomaticallyEnablesLowLightBoostWhenAvailable:YES];
        [self.avCamera unlockForConfiguration];
    }

    [[PNUserPreferences shared] setPreference:@"still_camera_last_position" object:@(self.cameraPosition)];
}

@end