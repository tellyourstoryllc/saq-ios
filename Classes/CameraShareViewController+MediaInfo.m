//
//  CameraShareViewController+MediaInfo.m
//  FFM
//
//  Created by Jim Young on 4/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "CameraShareViewController+MediaInfo.h"
#import "AFNetworkReachabilityManager.h"
#import "PNUserPreferences.h"
#import "MediaOverlayView.h"
#import "UIImage+Utility.h"
#import "PNVideoComposer.h"
#import "App.h"
#import "Api+MediaInfo.h"

@implementation StoryShareViewController (MediaInfo)

- (NSDictionary*)paramsForMediaInfo:(NSDictionary*)mediaInfo {
    return [Api paramsForMediaInfo:mediaInfo];
}

- (BOOL)isCreator {
    return [self.info[@"author"] isEqualToString:[App username]];
}

- (NSString*)videoUploadQuality {
    return ([[PNUserPreferences shared] boolPreference:@"kSaveBandwidthPrefKey"] && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) ? AVAssetExportPresetLowQuality : AVAssetExportPresetMediumQuality;
}

- (UIImage*)processedImage {
    if ([[PNUserPreferences shared] boolPreference:@"kSaveBandwidthPrefKey"] && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        id lowQualityImageSettings = [Configuration settingFor:@"low_quality_max_dim"];
        int lowQualityMaxDim = lowQualityImageSettings ? [lowQualityImageSettings intValue] : 640;
        return [self.image constrainedToSize:CGSizeMake(lowQualityMaxDim, lowQualityMaxDim)];
    }
    else {
        id normalQualityImageSettings = [Configuration settingFor:@"normal_quality_max_dim"];
        int normalQualityMaxDim = normalQualityImageSettings ? [normalQualityImageSettings intValue] : 1600;
        return [self.image constrainedToSize:CGSizeMake(normalQualityMaxDim, normalQualityMaxDim)];
    }
}

- (UIImage*)imageByWatermarking:(UIImage*)image {
    MediaOverlayView* overlayView = [[MediaOverlayView alloc] initWithFrame:CGRectMake(0,0,image.size.width,image.size.height)];
    overlayView.info = self.info;
    UIImage* overlay = [UIImage imageWithView:overlayView];
    return [image overlayImage:overlay
                       inFrame:CGRectMake(0,0,overlay.size.width,overlay.size.height)
                     blendMode:kCGBlendModeNormal
                         alpha:1.0];
}

- (void)watermarkVideoUrl:(NSURL*)videoUrl
                   preset:(NSString*)preset
           withCompletion:(void(^)(NSURL* watermarkedVideoUrl, NSError* error))completion {

    [PNVideoComposer processVideoUrl:videoUrl
                              preset:preset
                            filetype:AVFileTypeMPEG4
               constructingWithBlock:^(CALayer *baseLayer, CALayer *videoLayer, CGSize renderSize) {

                   // Add watermark
                   if (self.info) {
                       CGRect frame = CGRectMake(0,0,renderSize.width,renderSize.height);
                       MediaOverlayView* overlay = [[MediaOverlayView alloc] initWithFrame:frame];
                       overlay.info = self.info;
                       UIImage* overlayImage = [UIImage imageWithView:overlay];
                       CALayer *overlayLayer = [CALayer layer];
                       overlayLayer.frame = overlay.frame;
                       overlayLayer.contents = (__bridge id)overlayImage.CGImage;
                       overlayLayer.opacity = 1.0;
                       [baseLayer addSublayer:overlayLayer];
                   }
               }
                          exportWith:^(AVAssetExportSession *exportSession) {
                          }
                      withCompletion:completion];
}

@end
