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
        self.plusLabel.font = [[Theme current] extraBoldFontWithSize:142];
        self.plusLabel.textColor = [COLOR(blackColor) colorWithAlphaComponent:0.88];
        self.plusLabel.text = @"+";
        [self.contentView addSubview:self.plusLabel];

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
}
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

    return self;
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