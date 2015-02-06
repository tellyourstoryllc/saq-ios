//
//  WallpaperSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/10/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "WallpaperSettingsCell.h"
#import "PNCamera.h"
#import "User.h"
#import "SkyAccount.h"
#import "UIImageView+AFNetworking.h"
#import "StillCamera.h"
#import "AlertView.h"
#import "UploadProgressAlertView.h"
#import "Api.h"

@interface WallpaperSettingsCell() <PNCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView* wallView;
@property (nonatomic, strong) UIImageView* magnifiedView;
@property (nonatomic, strong) PNButton* updateButton;
@property (nonatomic, strong) SkyAccount* myAccount;

@end

@implementation WallpaperSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wallView = [[UIImageView alloc] initWithFrame:CGRectMake(40,0,60,100)];
        self.wallView.backgroundColor = COLOR(whiteColor);
        self.wallView.contentMode = UIViewContentModeScaleAspectFill;
        self.wallView.clipsToBounds = YES;
        self.wallView.userInteractionEnabled = YES;
        [self addChild:self.wallView];

        // Gesture for magnifying image
        UILongPressGestureRecognizer* gest = [[UILongPressGestureRecognizer alloc] init];
        gest.minimumPressDuration = 0.1;
        [gest addTarget:self action:@selector(magnifyImage:)];
        [self.wallView addGestureRecognizer:gest];

        self.updateButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,160,40)];
        [self.updateButton setTitle:@"Set wallpaper" forState:UIControlStateNormal];
        [self.updateButton setBorderWithColor:COLOR(darkGrayColor) width:1.0];
        self.updateButton.buttonColor = [UIColor clearColor];
        self.updateButton.titleLabel.font = FONT(14);
        [self.updateButton setTitleColor:COLOR(darkGrayColor) forState:UIControlStateNormal];
        self.updateButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.wallView.frame)+10, CGRectGetMinY(self.wallView.frame)+10, self.updateButton.frame);
        [self.updateButton addTarget:self action:@selector(onEdit) forControlEvents:UIControlEventTouchUpInside];
        [self addChild:self.updateButton];

        self.paddingY = 10;
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;

    NSString* wallpaper = [[SkyAccount mine] one_to_one_wallpaper_url];
    if (wallpaper) [self.wallView setImageWithURL:[NSURL URLWithString:wallpaper]];

    if (!self.myAccount) {
        self.myAccount = [SkyAccount mine];
        [self.myAccount addObserver:self forKeyPath:@"updated_at" options:NSKeyValueObservingOptionNew context:nil];
    }

    self.updateButton.frame = CGRectSetTopRight(b.size.width-20, CGRectGetMidY(self.wallView.frame)-20, self.updateButton.frame);
    [super layoutSubviews];
}

- (void)magnifyImage:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.magnifiedView = self.magnifiedView ?: [[UIImageView alloc] initWithFrame:self.window.bounds];
        self.magnifiedView.contentMode = UIViewContentModeScaleAspectFill;
        [self.magnifiedView setImage:self.wallView.image];
        [self.window addSubview:self.magnifiedView];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.magnifiedView removeFromSuperview];
    }
}

- (void)onEdit {
    CGRect cameraFrame = CGRectInset(self.window.bounds, 20, 20);
    StillCamera* camera = [[StillCamera alloc] initWithFrame:cameraFrame];
    camera.showCancelButton = YES;
    camera.delegate = self;
    camera.showFlipButton = NO;
    camera.cropToSquare = NO;
    camera.cameraPosition = AVCaptureDevicePositionBack;

    __weak WallpaperSettingsCell* weakSelf = self;
    __weak StillCamera* weakCam = camera;
    [camera.cameraRollButton setTappedBlock:^{
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = weakSelf;
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        [weakSelf.controller presentViewController:picker animated:YES completion:nil];
        [weakCam removeFromSuperview];
    }];
    [camera startPreview];
    [self.window addSubview:camera];
}

- (void)capturedImage:(UIImage*)newImage {
    UIImage* oldImage = self.wallView.image;
    self.wallView.image = newImage;
    PNActionSheet* sheet = [[PNActionSheet alloc] initWithTitle:@"Your wallpaper is seen by others when they chat with you"
                                                     completion:^(NSInteger buttonIndex, BOOL didCancel) {
                                                         if (buttonIndex == 0) {
                                                             [self saveImage:newImage];
                                                         }
                                                         else {
                                                             self.wallView.image = oldImage;
                                                         }
                                                     } cancelButtonTitle:@"Discard"
                                         destructiveButtonTitle:nil otherButtonArray:@[@"Update wallpaper"]];
    [sheet showInView:self];

}

- (void)cameraDidCancel:(id)recorder {
    [recorder removeFromSuperview];
}

- (void)cameraDidShutoff:(id)recorder {
    [recorder removeFromSuperview];
}

- (void)camera:(id)recorder didSnapshot:(UIImage*)screenshot {
    [self capturedImage:screenshot];
    [recorder removeFromSuperview];
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
        //
    }];
}

- (void)saveImage:(UIImage*)image {

    PNLOG(@"user.update_wallpaper");

    NSData* data = UIImageJPEGRepresentation([[image reorientedImage] imageByScalingProportionallyToFit:CGSizeMake(1440, 1440)], 0.8);

    UploadProgressAlertView* progressView = [[UploadProgressAlertView alloc] init];
    progressView.titleLabel.text = @"Saving";

    AFHTTPRequestOperation* uploadOperation =
    [[Api sharedApi] multipartRequestOperationWithHTTPMethod:@"POST"
                                                        path:@"/accounts/update"
                                                  parameters:nil
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                       [formData appendPartWithFileData:data
                                                                   name:@"one_to_one_wallpaper_image_file"
                                                               fileName:@"userwall.jpg"
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

#pragma mark KVO stuff

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[SkyAccount class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wallView setImageWithURL:[NSURL URLWithString:[[SkyAccount mine] one_to_one_wallpaper_url]] placeholderImage:nil];
        });
    }
}

- (void)dealloc {
    [self.magnifiedView removeFromSuperview];
    [self.myAccount removeObserver:self forKeyPath:@"updated_at"];
}

@end
