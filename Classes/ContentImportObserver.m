//
//  ContentImportObserver.m
//  NoMe
//
//  Created by Jim Young on 12/20/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ContentImportObserver.h"
#import "PasteBoardManager.h"
#import "MediaAssetManager.h"
#import "App.h"
#import "AppViewController.h"

@interface ContentImportObserver() {
    NSURL* _lastAssetUrl;
}

@end

@implementation ContentImportObserver

+ (instancetype)shared {

    static ContentImportObserver *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[ContentImportObserver alloc] init];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    return self;
}

- (void)didBecomeActive {
    [self performObservation];
}

- (void)performObservation {
    if ([App isLoggedIn]) {
        [[PasteBoardManager manager] importWithCompletion:^(UIImage *image, NSDictionary *metadata) {
            if (image) {
                [self importImage:image fromSource:@"clipboard" withParams:metadata];
            }
            else {
                [[MediaAssetManager manager] fetchLatestImageWithCompletion:^(NSURL *assetURL, UIImage *image, NSDate *date, NSDictionary *metadata) {
                    //
                    NSTimeInterval age = -1*[date timeIntervalSinceNow];
                    NSLog(@"checkkkkkkkkkkkkkk");
                    if (age < 60 && ![_lastAssetUrl isEqual:assetURL]) {

                        _lastAssetUrl = assetURL;

                        AlertView* av = [[AlertView alloc] initWithTitle:@"Import Picture?" message:nil andButtonArray:@[@"Yes", @"No"]];
                        av.verticalAlignment = AlertViewAlignHigh;
                        [av
                         showAfterPresent:^{
                             UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMakeCorners(10,
                                                                                                   CGRectGetMaxY(av.alertContainer.frame)+10,
                                                                                                   av.backgroundOverlay.bounds.size.width-10,
                                                                                                   av.backgroundOverlay.bounds.size.height-10)];
                             iv.image = image;
                             iv.contentMode = UIViewContentModeScaleAspectFit;
                             [av.backgroundOverlay addSubview:iv];

                         }
                         withCompletion:^(NSInteger buttonIndex) {
                             if (buttonIndex == 0) {
                                 [self importImage:image fromSource:@"library" withParams:nil];
                             }
                         }];
                    }
                }];
            }
        }];
    }
}

- (void)importImage:(UIImage*)image fromSource:(NSString*)source withParams:(NSDictionary*)params {
    params = params ?: @{};
    NSDictionary* newParams = [params mutableCopy];
    source = source ?: @"unknown";
    [newParams setValue:source forKey:@"source"];
    [[AppViewController sharedAppViewController] importImage:image withVideoUrl:nil andParams:newParams];
}

- (void)importVideo:(NSURL*)videoUrl fromSource:(NSString*)source withParams:(NSDictionary*)params {
    params = params ?: @{};
    NSDictionary* newParams = [params mutableCopy];
    source = source ?: @"unknown";
    [newParams setValue:source forKey:@"source"];
    [[AppViewController sharedAppViewController] importImage:nil withVideoUrl:videoUrl andParams:newParams];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
