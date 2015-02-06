//
//  MediaAssetManager.m
//  NoMe
//
//  Created by Jim Young on 12/6/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MediaAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EGOCache.h"

@implementation MediaAssetManager

+ (instancetype)manager
{
    static MediaAssetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MediaAssetManager new];
    });

    return manager;
}

- (void)saveImage:(UIImage*)image withCompletion:(void (^)(NSURL *assetURL, NSError *error))completion
{
    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:image.CGImage
                                                     orientation:ALAssetOrientationUp
                                                 completionBlock:^(NSURL *assetURL, NSError *error) {
                                                     if (completion)
                                                         completion(assetURL, error);
                                                 }];
}

- (void)saveVideo:(NSURL*)videoUrl withCompletion:(void (^)(NSURL *assetURL, NSError *error))completion
{
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                                       completionBlock:^(NSURL *assetURL, NSError *error) {
                                                           if (completion)
                                                               completion(assetURL, error);
                                                       }];
}

- (void)fetchLatestImageWithCompletion:(void (^)(NSURL *assetURL, UIImage* image, NSDate* date, NSDictionary* metadata))completion
{
    NSParameterAssert(completion);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block ALAsset* ass = nil;

    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.

    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

                               // Within the group enumeration block, filter to enumerate just photos.
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];

                               // Chooses the photo at the last index
                               [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {

                                   // The end of the enumeration is signaled by asset == nil.
                                   if (alAsset) {
                                       ass = alAsset;

                                       ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                       NSURL* assetUrl = [representation url];
                                       NSDate* date = [alAsset valueForProperty:ALAssetPropertyDate];
                                       UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];

                                       // Stop the enumerations
                                       *stop = YES; *innerStop = YES;
                                       completion(assetUrl, latestPhoto, date, representation.metadata);
                                       return;
                                   }
                               }];

                               if (!ass) completion(nil, nil, nil, nil);
                           }
                         failureBlock: ^(NSError *error) {
                             completion(nil, nil, nil, nil);
                         }];
}

- (void)fetchLatestVideoWithCompletion:(void (^)(NSURL *assetURL, NSURL* videoUrl, NSDate* date, NSNumber* duration, NSDictionary* metadata))completion
{
    NSParameterAssert(completion);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block ALAsset* ass = nil;

    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

                               [group setAssetsFilter:[ALAssetsFilter allVideos]];
                               [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {

                                   // The end of the enumeration is signaled by asset == nil.
                                   if (alAsset) {
                                       ass = alAsset;

                                       ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                       NSURL* assetUrl = [representation url];
                                       NSDate* date = [alAsset valueForProperty:ALAssetPropertyDate];
                                       NSNumber* duration = [alAsset valueForProperty:ALAssetPropertyDuration];

                                       Byte *buffer = (Byte*)malloc(representation.size);
                                       NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
                                       NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];

                                       NSString* cacheKey = @"media_asset_manager_latest_video.mov";
                                       EGOCache* cache = [EGOCache globalCache];
                                       [cache setData:data forKey:cacheKey];

                                       // Stop the enumerations
                                       *stop = YES; *innerStop = YES;
                                       NSURL* videoUrl = [cache urlForKey:cacheKey];
                                       completion(assetUrl, videoUrl, date, duration, representation.metadata);
                                       return;
                                   }
                               }];
                               if (!ass) completion(nil, nil, nil, nil, nil);
                           }
                         failureBlock: ^(NSError *error) {
                             completion(nil, nil, nil, nil, nil);
                         }];
}

@end
