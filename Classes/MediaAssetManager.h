//
//  MediaAssetManager.h
//  NoMe
//
//  Created by Jim Young on 12/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaAssetManager : NSObject

+ (instancetype)manager;

- (void)saveImage:(UIImage*)image withCompletion:(void (^)(NSURL *assetURL, NSError *error))completion;
- (void)saveVideo:(NSURL*)videoUrl withCompletion:(void (^)(NSURL *assetURL, NSError *error))completion;

- (void)fetchLatestImageWithCompletion:(void (^)(NSURL *assetURL, UIImage* image, NSDate* date, NSDictionary* metadata))completion;
- (void)fetchLatestVideoWithCompletion:(void (^)(NSURL *assetURL, NSURL* videoUrl, NSDate* date, NSNumber* duration, NSDictionary* metadata))completion;

@end
