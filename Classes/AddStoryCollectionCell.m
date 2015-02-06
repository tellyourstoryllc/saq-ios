//
//  AddStoryCollectionCell.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "AddStoryCollectionCell.h"
#import "PNUserPreferences.h"
#import "PNMonochromeFilter.h"

@interface AddStoryCollectionCell()
@property (nonatomic, strong) PNLabel* plusLabel;
@property (nonatomic, strong) PNLabel* label;
@end

@implementation AddStoryCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        NSLog(@"INIT AddStoryCollectionCell");
        self.backgroundColor = COLOR(whiteColor);

        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusAuthorized) {
            self.camcorder = [[AddStoryCamcorder alloc] initWithFrame:self.contentView.bounds];
            self.camcorder.userInteractionEnabled = NO;
            self.camcorder.alpha = 1.f;
            [self.contentView addSubview:self.camcorder];
        }

        self.plusLabel = [[PNLabel alloc] initWithFrame:self.contentView.bounds];
        self.plusLabel.textAlignment = NSTextAlignmentCenter;
        self.plusLabel.font = HEADFONT(142);
        self.plusLabel.textColor = [COLOR(orangeColor) colorWithAlphaComponent:0.66];
        self.plusLabel.text = @"+";
        [self.contentView addSubview:self.plusLabel];

        //        self.label = [[PNLabel alloc] initWithFrame:self.contentView.bounds];
        //        self.label.textAlignment = NSTextAlignmentCenter;
        //        self.label.transform = CGAffineTransformMakeRotation(-M_PI/3.f);
        //        self.label.font = HEADFONT(36);
        //        self.label.textColor = COLOR(purpleColor);
        //        self.label.text = @"Add Story";
        //        [self.contentView addSubview:self.label];

    }
    return self;
}

- (void)prepareForReuse {
    [self.camcorder stopPreview];
}

- (void)startCamera {
    [self.camcorder startPreview];
}

- (void)stopCamera {
    [self.camcorder stopPreview];
}

@end

@interface AddStoryCamcorder() {
    UIView* _snapFlashView;
}
@property (nonatomic, strong) UIView* recordView;
@property (nonatomic, strong) UIView* recordProgressView;
@end

@implementation AddStoryCamcorder

- (NSArray*)filterList {

    return @[             [GPUImageCropFilter class],
                          ];

//    PNMonochromeFilter* monoFilter = [PNMonochromeFilter new];
//    [monoFilter setUIColor:COLOR(grayColor)];
//
//    return @[
//             @{@"PNCompoundImageFilter":
//                   @{@"filters":
//                         @[
//                             //                             @{@"GPUImagePixellateFilter":@{@"fractionalWidthOfAPixel":@(.06)}},
//                             monoFilter
//                             ]
//                     }
//               },
//             ];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.recordingPaused = YES;
    self.cameraPosition = AVCaptureDevicePositionFront;
    self.disableAudio = NO;
    self.showCaptureButton = NO;
    self.mirrorFrontCamera = YES;
    self.maxRecordingDuration = 30.0;

    _snapFlashView = [[UIView alloc] initWithFrame:self.bounds];
    _snapFlashView.hidden = YES;
    [self addSubview:_snapFlashView];

    _recordView = [[UIView alloc] initWithFrame:self.bounds];
    _recordView.hidden = YES;
    _recordView.backgroundColor = [COLOR(redColor) colorWithAlphaComponent:0.5];
    [self addSubview:_recordView];

    _recordProgressView = [[UIView alloc] initWithFrame:self.bounds];
    _recordProgressView.backgroundColor = [COLOR(orangeColor) colorWithAlphaComponent:0.5];
    [_recordView addSubview:_recordProgressView];

    return self;
}

- (void)didResumeRecording {
    self.recordView.hidden = NO;
    if (!self.recordingProgressBlock) {
        __weak AddStoryCamcorder* weakSelf = self;
        [self setRecordingProgressBlock:^(NSTimeInterval t, CGFloat p) {
            CGFloat percentage = p;
            CGRect r = CGRectMake(0, 0, weakSelf.bounds.size.width*percentage, weakSelf.bounds.size.height);
            weakSelf.recordProgressView.frame = r;
        }];
    }
}

- (void)didStopRecording {
    self.recordView.hidden = YES;
}

- (void)startPreview {
    NSNumber* cameraPositionPref = [[PNUserPreferences shared] getPreference:@"camcorder_last_position"];
    self.cameraPosition = cameraPositionPref ? cameraPositionPref.integerValue : AVCaptureDevicePositionFront;
    [super startPreview];
}

- (void) snapWithCompletion:(void (^)(UIImage* snap))completion {

    // Flash effect to indicate snapshot was taken.
    _snapFlashView.backgroundColor = COLOR(whiteColor);
    _snapFlashView.alpha = 1.0;
    _snapFlashView.frame = self.bounds;
    _snapFlashView.hidden = NO;
    [UIView animateWithDuration:0.25 delay:0.2 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _snapFlashView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         _snapFlashView.hidden = YES;
                         _snapFlashView.alpha = 1.0;
                     }];

    [self.gpuCamera capturePhotoAsImageProcessedUpToFilter:self.cropper
                                           withOrientation:[self snapshotOrientation]
                                     withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                         if (completion) completion(processedImage);
                                     }];
}

- (void)startPreviewWithCompletion:(void (^)(BOOL success))completion
{
    void (^completionBlock)(BOOL) = ^(BOOL suc) {
        [self startRecordingWithCompletion:^(BOOL success) {
            if (completion) completion(success);
        }];
    };

    self.recordingPaused = YES;
    [super startPreviewWithCompletion:completionBlock];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.stopRecordingButton.hidden = YES;
    self.composeView.hidden = YES;
}

@end