//  Copyright (c) 2013 Perceptual Networks. All rights reserved.

#import "PNButton.h"
#import <AVFoundation/AVFoundation.h>
#import "StillCamera.h"

@interface GenericCameraButton : PNButton

@property(nonatomic, copy) void(^snappedBlock)(UIImage* image);

@property (nonatomic, weak) UIViewController* presentingController;
@property (nonatomic, weak) UIView* targetView;
@property (nonatomic, assign) CGRect targetFrame;

@property (nonatomic, assign) NSTimeInterval oneShotDelay;

@property (nonatomic, assign) BOOL allowsDoodling;
@property (nonatomic, assign) BOOL showCancelButton;
@property (nonatomic, assign) BOOL showFlipButton;
@property (nonatomic, assign) BOOL showCaptureButton;
@property (nonatomic, assign) BOOL showCameraRollButton;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@property (nonatomic, strong) StillCamera* camcorder;

@property (nonatomic, strong) PNButton* me; // <-- intentionally create a retain cycle.

- (void) snappedImage:(UIImage*)image;
- (void) presentCamera;
- (void) presentWalkieTalkie;
- (void) selectCameraRoll;

@end