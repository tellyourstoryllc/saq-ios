//
//  LinearCreateAccountPanel.m
//  NoMe
//
//  Created by Jim Young on 11/21/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "LinearCreateAccountPanel.h"
#import "Api.h"
#import "App.h"
#import "Story.h"
#import "PNFaceDetector.h"
#import "PNVideoCompressor.h"
#import "SpinnerImageView.h"
#import "VideoURLView.h"

@interface LinearCreateAccountPanel()

@property (nonatomic, strong) VideoURLView* videoView;
@property (nonatomic, strong) SpinnerImageView* spinner;

@end

@implementation LinearCreateAccountPanel

- (BOOL)isNeeded {
    BOOL valid = YES;

    if (![self.controller valueForKey:@"email"]) return NO;
    if (![self.controller valueForKey:@"password"]) return NO;
    if (![self.controller valueForKey:@"birthdate"]) return NO;
    if (![self.controller valueForKey:@"gender"]) return NO;
    if (![self.controller valueForKey:@"videoFileURL"]) return NO;

    return valid;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.backgroundColor = COLOR(darkGrayColor);

    self.videoView = [[VideoURLView alloc] initWithFrame:self.bounds];
    self.videoView.muted = YES;
    self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.videoView];

    self.spinner = [SpinnerImageView new];
    [self.spinner sizeToFit];
    [self addSubview:self.spinner];
    self.spinner.alpha = 0.0;

    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
    self.videoView.frame = b;
    self.spinner.center = CGPointMake(b.size.width/2, b.size.height*(1-1/GOLDEN_MEAN));
}

- (void)didAppear {

    self.videoView.videoUrl = [NSURL URLWithString:@"http://test-media.know.me.s3.amazonaws.com/1376425910a437792fabcb2406_720p.mp4"];
    [self.videoView play];

    if (![App isLoggedIn]) {
        [self doCreateAccount];

        [UIView animateWithDuration:1.0 animations:^{
            self.spinner.alpha = 1.0;
        }];
    }
}

- (void)doCreateAccount {

    static BOOL isCreating;
    if (isCreating) return;

    isCreating = YES;

    self.spinner.hidden = NO;

    [self createUserWithCompletion:^(BOOL success, NSError *error) {
        if (success) {

            NSURL* storyVideoUrl = [self.controller valueForKey:@"videoFileURL"];
            UIImage* overlayImage = [self.controller valueForKey:@"videoOverlay"];

            [PNVideoCompressor
             compressVideoUrl:storyVideoUrl
             preset:AVAssetExportPresetMediumQuality
             filetype:AVFileTypeMPEG4
             exportWith:^(AVAssetExportSession *exportSession) {
                 // Skip the first tenths of a second to avoid possible black frame.
                 exportSession.timeRange = CMTimeRangeMake(CMTimeMake(2, 10), kCMTimePositiveInfinity);
             }
             withCompletion:^(NSURL *compressedVideoUrl, NSError *error) {

                 [[PNFaceDetector new] detectFaceInVideoUrl:compressedVideoUrl withCompletion:^(BOOL hasFace) {

                     NSMutableDictionary* params = [@{@"permission":@"public",
                                                      @"source":@"camera"} mutableCopy];
                     if (hasFace)
                         [params setValue:@"yes" forKey:@"has_face"];

                     [Story uploadVideo:compressedVideoUrl
                             andOverlay:overlayImage
                             withParams:params
                          andCompletion:^(Story *newStory) {

                              [[NSFileManager defaultManager] removeItemAtURL:compressedVideoUrl error:nil];
                              self.spinner.hidden = YES;
                              [self exitRegistration];
                              isCreating = NO;

                          }];

                     // If has face, also upload screenshot as avatar image?
                     // XXX
                     
                 }];

             }];
        }
    }];
}

@end
