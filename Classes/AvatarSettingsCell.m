//
//  AvatarSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/6/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "AvatarSettingsCell.h"
#import "PNCamera.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "StillCamera.h"
#import "AlertView.h"
#import "UploadProgressAlertView.h"
#import "Api.h"
#import "UserAvatarView.h"
#import "PNVideoCompressor.h"
#import "SavedApiRequest.h"
#import "UIView+Cutout.h"

@interface AvatarSettingsCell() <PNCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UserAvatarView* avatarImageView;
@property (nonatomic, strong) UIView* avatarMask;
@property (nonatomic, strong) UIImageView* magnifiedView;
@property (nonatomic, strong) PNButton* updateButton;

@property (nonatomic, strong) StillCamera* camera;
@property (nonatomic, strong) PNButton* snapButton;
@property (nonatomic, strong) PNButton* importButton;
@property (nonatomic, strong) PNButton* cancelButton;

@property (nonatomic, strong) User* me;
@end

@implementation AvatarSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.avatarImageView = [[UserAvatarView alloc] initWithFrame:CGRectMake(20,0,100,100)];
        self.avatarImageView.layer.cornerRadius = 50;
        self.avatarImageView.userInteractionEnabled = YES;
        [self addChild:self.avatarImageView];

        self.avatarMask = [[UIView alloc] initWithFrame:self.avatarImageView.frame];
        self.avatarMask.backgroundColor = COLOR(defaultBackgroundColor);
        self.avatarMask.layer.mask = [self.avatarMask circularCutoutLayerWithRadius:CGRectGetWidth(self.avatarMask.frame)/2];
        [self addChild:self.avatarMask];

        self.updateButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,120,40)];
        [self.updateButton setTitle:@"Set portrait" forState:UIControlStateNormal];
        [self.updateButton setBorderWithColor:COLOR(darkGrayColor) width:1.0];
        self.updateButton.buttonColor = [UIColor clearColor];
        self.updateButton.titleLabel.font = FONT(14);
        [self.updateButton setTitleColor:COLOR(darkGrayColor) forState:UIControlStateNormal];
        self.updateButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.avatarImageView.frame)+10, CGRectGetMinY(self.avatarImageView.frame)+10, self.updateButton.frame);
        [self.updateButton addTarget:self action:@selector(onEdit) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.updateButton];

        self.snapButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,60)];
        self.snapButton.cornerRadius = 30;
        [self.snapButton setImage:[UIImage imageNamed:@"input-photo"] forState:UIControlStateNormal];
        self.snapButton.buttonColor = COLOR(greenColor);
        [self.snapButton addTarget:self action:@selector(onSnap) forControlEvents:UIControlEventTouchDown];
        self.snapButton.hidden = YES;
        [self addChild:self.snapButton];

        self.importButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.importButton.cornerRadius = 25;
        [self.importButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
        self.importButton.buttonColor = COLOR(grayColor);
        [self.importButton addTarget:self action:@selector(onImport) forControlEvents:UIControlEventTouchDown];
        self.importButton.hidden = YES;
        [self addChild:self.importButton];

        self.cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.cancelButton.cornerRadius = 25;
        self.cancelButton.buttonColor = COLOR(grayColor);
        [self.cancelButton setImage:[UIImage imageNamed:@"camera-close"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchDown];
        self.cancelButton.hidden = YES;
        [self addChild:self.cancelButton];

        self.paddingY = 10;
        [self sizeToFit];

        self.me = [User me];
        self.avatarImageView.user = self.me;
    }
    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
    self.updateButton.frame = CGRectSetTopRight(b.size.width-20, CGRectGetMidY(self.avatarImageView.frame)-20, self.updateButton.frame);

    self.cancelButton.frame = CGRectSetMiddleRight(CGRectGetMaxX(self.updateButton.frame), CGRectGetMidY(self.updateButton.frame), self.cancelButton.frame);
    self.importButton.frame = CGRectSetMiddleRight(CGRectGetMinX(self.cancelButton.frame)-4, CGRectGetMidY(self.cancelButton.frame), self.importButton.frame);
    self.snapButton.frame = CGRectSetMiddleRight(CGRectGetMinX(self.importButton.frame)-4, CGRectGetMidY(self.cancelButton.frame), self.snapButton.frame);
    [super layoutSubviews];
}

- (void)onEdit {
    CGRect cameraFrame = self.avatarImageView.frame;
    self.camera = [[StillCamera alloc] initWithFrame:cameraFrame];
    self.camera.showCancelButton = NO;
    self.camera.delegate = self;
    self.camera.showFlipButton = NO;
    self.camera.cameraPosition = AVCaptureDevicePositionFront;
    self.camera.controlsYoverlap = 200.0;
    self.camera.recordButton.hidden = YES;
    self.camera.cameraRollButton.hidden = YES;
    self.camera.cropToSquare = NO;
    [self addChild:self.camera];
    [self.contentView bringSubviewToFront:self.avatarMask];
    [self.camera startPreview];

    self.updateButton.hidden = YES;
    self.snapButton.hidden = NO;
    self.importButton.hidden = NO;
    self.cancelButton.hidden = NO;
}

- (void)onSnap {
    [self.camera takeSnapshot];
}

- (void)onImport {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.mediaTypes = @[(NSString*)kUTTypeImage];
    [self.controller presentViewController:picker animated:YES completion:^{
        [self.camera removeFromSuperview];
    }];
}

- (void)onCancel {
    [self.camera removeFromSuperview];
    self.updateButton.hidden = NO;
    self.snapButton.hidden = YES;
    self.importButton.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void)capturedImage:(UIImage*)newImage {
    UIImage* oldImage = self.avatarImageView.image;
    self.avatarImageView.image = newImage;
    PNActionSheet* sheet = [[PNActionSheet alloc] initWithTitle:nil
                                                     completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                                         if (buttonIndex == 0) {
                                                             [self saveImage:newImage];
                                                             [self onCancel];
                                                         }
                                                         else {
                                                             self.avatarImageView.image = oldImage;
                                                             [self addChild:self.camera];
                                                             [self.contentView bringSubviewToFront:self.avatarMask];
                                                         }

                                                     } cancelButtonTitle:@"Discard"
                                         destructiveButtonTitle:nil otherButtonArray:@[@"Save avatar"]];
    [sheet showInView:self];

}

- (void)cameraDidCancel:(id)recorder {
    [self onCancel];
}

- (void)cameraDidShutoff:(id)recorder {
    [self onCancel];
}

- (void)camera:(id)recorder didSnapshot:(UIImage*)screenshot {
    [self capturedImage:screenshot];
    [self.camera playShutterSound];
    [self.camera removeFromSuperview];
}

#pragma mark UIImagePickerDelegate methods (for picking from camera roll)

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self capturedImage:image];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self onCancel];
    }];
}

- (void)saveImage:(UIImage*)image {

    PNLOG(@"user.update_avatar");

    NSData* data = UIImageJPEGRepresentation([[image reorientedImage] imageByScalingProportionallyToFit:CGSizeMake(600, 600)], 0.8);

    UploadProgressAlertView* progressView = [[UploadProgressAlertView alloc] init];
    progressView.titleLabel.text = @"Saving";

    AFHTTPRequestOperation* uploadOperation =
    [[Api sharedApi] multipartRequestOperationWithHTTPMethod:@"POST"
                                                        path:@"/users/update"
                                                  parameters:nil
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                       [formData appendPartWithFileData:data
                                                                   name:@"avatar_image_file"
                                                               fileName:@"me.jpg"
                                                               mimeType:@"image/jpeg"];
                                   }
                                                 andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {
                                                     [progressView dismiss];
                                                 }];
    [progressView showInView:self.window];

    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float p = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
        if (p < 1)
            [progressView setProgress:p];
        else
            [progressView dismiss];
    }];

    [[Api sharedApi] enqueueOperation:uploadOperation];
}

- (void)dealloc {
    [self.magnifiedView removeFromSuperview];
}

@end
