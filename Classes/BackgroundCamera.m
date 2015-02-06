//
//  BackgroundCamera.m
//  SnapCracklePop
//
//  Created by Jim Young on 11/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "BackgroundCamera.h"

@implementation BackgroundCamera

- (NSArray*)filterList {
    return @[
             [GPUImagePixellateFilter class],
             ];
}


- (NSDictionary*)filterParams {
    return @{
             @"GPUImagePixellateFilter":@{@"fractionalWidthOfAPixel":@(.06)},
             };
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.cameraPosition = AVCaptureDevicePositionFront;
    self.showCaptureButton = NO;
    self.disableAudio = YES;
    self.cropToSquare = NO;
    self.showFlipButton = NO;
    self.allowFilterSwipes = NO;
    self.filteredAudio = NO;

    return self;
}

- (void)startPreviewWithCompletion:(void (^)(BOOL success))completion {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [super startPreviewWithCompletion:completion];
    }
    else if (completion)
        completion(NO);
}

@end
