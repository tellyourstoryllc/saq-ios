//
//  UpdateAvatarButton.m
//  groups
//
//  Created by Jim Young on 12/10/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "UpdateAvatarButton.h"
#import "UploadProgressAlertView.h"
#import "Api.h"
#import "ButtonAlertView.h"

@implementation UpdateAvatarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showCaptureButton = YES;
        self.showCancelButton = YES;
        self.showCameraRollButton = YES;
        self.cameraPosition = AVCaptureDevicePositionFront;
        self.allowsDoodling = NO;
    }
    return self;
}

- (void) snappedImage:(UIImage *)image {
    PNLOG(@"user.update_avatar_button.snapped");

    ButtonAlertView* sv = [[ButtonAlertView alloc] init];
    sv.titleLabel.text = @""; // <-- needed for formatting. don't delete.
    
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    iv.layer.cornerRadius = 50;
    iv.clipsToBounds = YES;
    iv.image = image;
    sv.imageView = iv;

    PNButton* okButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,100,60)];
    [okButton setTitle:@"Save profile photo" forState:UIControlStateNormal];
    okButton.buttonColor = COLOR(greenColor);
    okButton.cornerRadius = 5.0;
    [okButton setTappedBlock:^{
        [sv dismiss];
        [self uploadImage:image];
    }];
    [sv addButton:okButton];

    PNButton* retryButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,100,60)];
    retryButton.buttonColor = COLOR(darkGrayColor);
    retryButton.cornerRadius = 5.0;
    [retryButton setTitle:@"Retake" forState:UIControlStateNormal];
    [retryButton setTappedBlock:^{
        [sv dismiss];
        [self presentCamera];
    }];
    [sv addButton:retryButton];

    PNButton* cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,100,40)];
    cancelButton.buttonColor = [UIColor clearColor];
    cancelButton.cornerRadius = 5.0;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTappedBlock:^{
        [sv dismiss];
    }];

    [sv addButton:cancelButton];

    [sv show];
}

- (void) uploadImage:(UIImage *)image {

    NSData* data = UIImageJPEGRepresentation([image reorientedImage], 0.8);

    UploadProgressAlertView* progressView = [[UploadProgressAlertView alloc] init];
    progressView.titleLabel.text = @"Saving";

    AFHTTPRequestOperation* uploadOperation =
    [[Api sharedApi] multipartRequestOperationWithHTTPMethod:@"POST"
                                                        path:@"/users/update"
                                                  parameters:nil
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                       [formData appendPartWithFileData:data
                                                                   name:@"avatar_image_file"
                                                               fileName:@"pic.jpg"
                                                               mimeType:@"image/jpeg"];
                                   }
                                                 andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {
                                                     [progressView dismiss];
                                                     [super snappedImage:image];
                                                 }];

    PNButton* cancelButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,100,40)];
    cancelButton.buttonColor = COLOR(grayColor);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];

    __weak AFHTTPRequestOperation* weakOperation = uploadOperation;
    __weak UploadProgressAlertView* weakProgress = progressView;
    [cancelButton setTappedBlock:^{
        [weakOperation cancel];
        [weakProgress dismiss];
    }];

    [progressView addButton:cancelButton];
    [progressView showInView:self.targetView];

    [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        float p = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
        if (p < 1)
            [progressView setProgress:p];
        else
            [progressView dismiss];
    }];

    [[Api sharedApi] enqueueOperation:uploadOperation];

}

@end
