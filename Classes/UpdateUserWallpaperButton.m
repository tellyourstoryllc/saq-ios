//
//  UpdateUserWallpaperButton.m
//  groups
//
//  Created by Jim Young on 12/10/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "UpdateUserWallpaperButton.h"
#import "UploadProgressAlertView.h"
#import "Api.h"

@implementation UpdateUserWallpaperButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showCaptureButton = YES;
        self.showCancelButton = YES;
        self.showCameraRollButton = YES;
        self.cameraPosition = AVCaptureDevicePositionBack;
        self.allowsDoodling = NO;
    }
    return self;
}

- (void) presentCamera {
    [super presentCamera];
    self.camcorder.cropToSquare = NO;
}

- (void) snappedImage:(UIImage *)image {
    PNLOG(@"user.update_wallpaper_button.snapped");
    [self uploadImage:image];
}

- (void) uploadImage:(UIImage *)image {

    NSData* data = UIImageJPEGRepresentation([image reorientedImage], 0.8);

    UploadProgressAlertView* progressView = [[UploadProgressAlertView alloc] init];
    progressView.titleLabel.text = @"Transmitting";

    AFHTTPRequestOperation* uploadOperation =
    [[Api sharedApi] multipartRequestOperationWithHTTPMethod:@"POST"
                                                        path:@"/accounts/update"
                                                  parameters:nil
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                       [formData appendPartWithFileData:data
                                                                   name:@"one_to_one_wallpaper_image_file"
                                                               fileName:@"wallpaper.jpg"
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
