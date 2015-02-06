//
//  CameraShareViewController+MediaInfo.h
//  FFM
//
//  Created by Jim Young on 4/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryShareViewController.h"

@interface StoryShareViewController (MediaInfo)

- (NSDictionary*)paramsForMediaInfo:(NSDictionary*)mediaInfo;
- (BOOL)isCreator;
- (NSString*)videoUploadQuality;
- (UIImage*)processedImage;

- (UIImage*)imageByWatermarking:(UIImage*)image;

- (void)watermarkVideoUrl:(NSURL*)videoUrl
                   preset:(NSString*)preset
           withCompletion:(void(^)(NSURL* watermarkedVideoUrl, NSError* error))completion;

@end