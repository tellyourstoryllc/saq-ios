//  Copyright (c) 2013 Perceptual Networks. All rights reserved.

#import "GenericCameraButton.h"
#import "BaseMediaEditController.h"
#import "PNKit.h"
#import "Api.h"
#import "UploadProgressAlertView.h"
#import "UIImage+Utility.h"

#import "GroupViewController.h"

@interface GenericCameraButton()<PNCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView* overlay;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) BOOL pressAndHoldEnabled;
@property (nonatomic, assign) BOOL isTouching;

@end

//--

@implementation GenericCameraButton

- (UIView*)targetView {
    return _targetView ?: self.window;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouching = YES;
    if (self.oneShotDelay > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.oneShotDelay target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }

    CGRect frame = (CGRectEqualToRect(self.targetFrame, CGRectZero)) ? self.targetView.bounds : self.targetFrame;
    self.camcorder = self.camcorder ?: [[StillCamera alloc] initWithFrame:frame];
    self.camcorder.delegate = self;

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isTouching = NO;
    UITouch *touch = [touches anyObject];
    if (self.pressAndHoldEnabled) {
        [self.camcorder takeSnapshot];
        self.pressAndHoldEnabled = NO;
    }
    else if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self presentCamera];
        self.hidden = YES;
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.isTouching = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)timerFired {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isTouching) {
            self.pressAndHoldEnabled = YES;
            CGAffineTransform magnify = CGAffineTransformMakeScale(1.5, 1.5);
            [UIView animateWithDuration:0.5 animations:^{
                self.transform = magnify;
            } completion:^(BOOL finished) {
                if (self.isTouching) [self presentWalkieTalkie];
            }];
        }
    });
}

- (void)presentCamera {
    assert(!self.presentingController || self.allowsDoodling || self.showCameraRollButton);

    self.me = self; // <-- create a retain cycle so button doesn't get dealloc'ed behind our back. undo this when camera finishes snapping or cancels.
    self.overlay = [[UIView alloc] initWithFrame:self.targetView.bounds];
    self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.88];
    [self.targetView addSubview:self.overlay];
    [self.targetView addSubview:self.camcorder];

    self.camcorder.showCancelButton = self.showCancelButton;
    self.camcorder.showFlipButton = self.showFlipButton;
    self.camcorder.showCaptureButton = self.showCaptureButton;
    self.camcorder.cameraRollButton.hidden = !self.showCameraRollButton;
    self.camcorder.cameraPosition = self.cameraPosition;

    [self.camcorder.cameraRollButton addTarget:self action:@selector(selectCameraRoll) forControlEvents:UIControlEventTouchUpInside];
    [self.camcorder startPreview];
}

- (void)presentWalkieTalkie {
    self.me = self; // <-- create a retain cycle so button doesn't get dealloc'ed behind our back. undo this when camera finishes snapping or cancels.
    self.overlay = [[UIView alloc] initWithFrame:self.targetView.bounds];
    self.overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.targetView addSubview:self.overlay];
    [self.targetView addSubview:self.camcorder];

    self.camcorder.showCancelButton = NO;
    self.camcorder.showFlipButton = NO;
    self.camcorder.showCaptureButton = NO;
    self.camcorder.cameraRollButton.hidden = YES;
    [self.camcorder startPreview];
}

- (void) cameraDidCancel:(id)recorder {
    [self.overlay removeFromSuperview];
    [recorder removeFromSuperview];
    [recorder shutoffCamera];
    self.hidden = NO;
    if (self.snappedBlock) self.snappedBlock(nil);
    self.me = nil;
}

- (void) camera:(id)recorder didSnapshot:(UIImage *)screenshot {
    StillCamera* camera = (StillCamera*)recorder;

    [self.overlay removeFromSuperview];
    [camera removeFromSuperview];
    [camera shutoffCamera];
    self.transform = CGAffineTransformIdentity;
    self.hidden = NO;

    UIImage* orientedImage;

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIImageOrientation imageOrientation = (UIImageOrientation)deviceOrientation;

    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;

        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = (camera.cameraPosition == AVCaptureDevicePositionFront) ? UIImageOrientationRight : UIImageOrientationLeft;
            break;

        case UIDeviceOrientationLandscapeRight:
            imageOrientation = (camera.cameraPosition == AVCaptureDevicePositionFront) ? UIImageOrientationLeft : UIImageOrientationRight;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;

        default:
            break;
    }

    orientedImage = [[UIImage imageWithCGImage:[screenshot CGImage] scale:1.0 orientation:imageOrientation] reorientedImage];

    if (self.allowsDoodling) {
        BaseMediaEditController* ppc = [[BaseMediaEditController alloc] init];
        ppc.photo = orientedImage;
        [self.presentingController presentViewController:ppc animated:YES completion:nil];
    }
    else {
        [self snappedImage:orientedImage];
    }
}

- (void) selectCameraRoll {
    assert(self.presentingController);

    [self.camcorder shutoffCamera];
    self.hidden = NO;

    [UIView animateWithDuration:0.5 animations:^{
        self.overlay.alpha = 0.0;
        self.camcorder.transform = CGAffineTransformMakeTranslation(0, self.overlay.bounds.size.height);

    } completion:^(BOOL finished) {
        [self.overlay removeFromSuperview];
        [self.camcorder removeFromSuperview];
        self.camcorder.alpha = 1.0;
        self.camcorder.transform = CGAffineTransformIdentity;

        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self.presentingController presentViewController:picker animated:YES completion:nil];
    }];
}

- (void) snappedImage:(UIImage*)image {
    if (self.snappedBlock) self.snappedBlock(image);
    self.me = nil;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    if (self.allowsDoodling) {
        BaseMediaEditController* ppc = [[BaseMediaEditController alloc] init];
        ppc.photo = image;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.presentingController presentViewController:ppc animated:YES completion:nil];
        }];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self snappedImage:image];
        }];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark PhotoPreviewControllerDelegate methods

- (void) mediaEditor:(BaseMediaEditController*)preview didPublish:(UIImage*)image {
    [preview dismissViewControllerAnimated:YES
                                completion:^{
                                    [self snappedImage:image];
                                }];
}

- (void) mediaEditorDidCancel:(BaseMediaEditController*)preview {
    [preview dismissViewControllerAnimated:YES completion:nil];
}

@end
