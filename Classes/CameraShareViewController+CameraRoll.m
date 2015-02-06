//
//  CameraShareViewController+CameraRoll.m
//
//
//  Created by Jim Young on 3/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>

#import "CameraShareViewController+CameraRoll.h"
#import "CameraShareViewController+MediaInfo.h"
#import "Api.h"
#import "StatusView.h"
#import "PNVideoCompressor.h"
#import "PNVideoWatermarker.h"
#import "MediaOverlayView.h"

@implementation StoryShareViewController (CameraRoll)

- (void)saveToCameraRoll {

    if (self.videoURL) {

        void (^saveVideo)(NSURL*, NSError*) = ^void(NSURL* url, NSError* error) {

            [PNVideoComposer processVideoUrl:self.videoURL
                                      preset:AVAssetExportPresetMediumQuality
                                    filetype:AVFileTypeMPEG4
                              adjustRotation:YES
                       constructingWithBlock:^(CALayer *baseLayer, CALayer *videoLayer, CGSize renderSize) {

                           // Add watermark
                           if (self.info && !self.isCreator) {
                               CGRect frame = CGRectMake(0,0,renderSize.width,renderSize.height);
                               MediaOverlayView* overlay = [[MediaOverlayView alloc] initWithFrame:frame];
                               overlay.info = self.info;
                               UIImage* overlayImage = [UIImage imageWithView:overlay];
                               CALayer *overlayLayer = [CALayer layer];
                               overlayLayer.frame = overlay.frame;
                               overlayLayer.contents = (__bridge id)overlayImage.CGImage;
                               overlayLayer.opacity = 0.88;
                               [baseLayer addSublayer:overlayLayer];
                           }
                       }
                                  exportWith:^(AVAssetExportSession *exportSession) {
                                  }

                              withCompletion:^(NSURL *watermarkedVideoUrl, NSError *error) {
                                  if (error) return;

                                  [[[ALAssetsLibrary alloc] init]
                                   writeVideoAtPathToSavedPhotosAlbum:watermarkedVideoUrl
                                   completionBlock:^(NSURL *assetURL, NSError *error) {
                                       if (error) {
                                           [StatusView showTitle:@"Unable to save video"
                                                         message:[NSString stringWithFormat:@"You must go to device Settings > Privacy > Photos > Turn on %@.", kAppTitle]
                                                      completion:nil
                                                        duration:5];
                                           [Logger log:@"video.save.fail.noauth"];
                                       } else {
                                           [Logger log:@"video.save.success"];

                                           if ([self.delegate respondsToSelector:@selector(shareControllerDidSave:)])
                                               [self.delegate shareControllerDidSave:self];

                                           if (self.info[@"forward_message_id"])
                                               [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/export", self.info[@"forward_message_id"]]
                                                              parameters:@{@"method":@"library"}
                                                                callback:nil];
                                       }
                                   }];
                              }];
        };

        on_background(^{
            saveVideo(self.videoURL, nil);
        });

    }
    else if (self.image) {

        UIImage* imageToSave = self.isCreator ? self.image : [self imageByWatermarking:[self processedImage]];

        ALAssetOrientation orientation;
        if (self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
            orientation = ALAssetOrientationDown;
        }
        else if (self.orientation == UIInterfaceOrientationLandscapeLeft) {
            orientation = (self.cameraPosition == AVCaptureDevicePositionFront) ? ALAssetOrientationLeft : ALAssetOrientationRight;
        }
        else if (self.orientation == UIInterfaceOrientationLandscapeRight) {
            orientation = (self.cameraPosition == AVCaptureDevicePositionFront) ? ALAssetOrientationRight : ALAssetOrientationLeft;
        }
        else {
            orientation = ALAssetOrientationUp;
        }

        [[[ALAssetsLibrary alloc] init]
         writeImageToSavedPhotosAlbum:imageToSave.CGImage
         orientation:orientation
         completionBlock:^(NSURL *assetURL, NSError *error) {
             if (error) {
                 [StatusView showTitle:@"Unable to save photo"
                               message:[NSString stringWithFormat:@"You must go to device Settings > Privacy > Photos > Turn on %@.", kAppTitle]
                            completion:nil
                              duration:5];
             }
             else {
                 [StatusView showTitle:@"Saved to Camera Roll" message:nil completion:nil duration:2.0];
                 if ([self.delegate respondsToSelector:@selector(shareControllerDidSave:)])
                     [self.delegate shareControllerDidSave:self];

                 if (self.info[@"forward_message_id"])
                     [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/export", self.info[@"forward_message_id"]]
                                    parameters:@{@"method":@"library"}
                                      callback:nil];
             }
         }];
    }
}

@end
