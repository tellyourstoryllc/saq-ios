//
//  StoryCamcorder.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryCamera.h"
#import "PNUserPreferences.h"

@interface StoryCamera()

@end

@implementation StoryCamera

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.publishView = [StoryPublishView new];
    [self.publishView sizeToFit];
    [self.composeView addSubview:self.publishView];

    [self.publishButton removeFromSuperview];

    return self;
}

- (void) configureButtons {
    [super configureButtons];
    self.cancelButton.hidden = self.isRecording && !self.recordingPaused;

    if (self.isComposing)
        [self.publishView startAnimating];
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect publishViewFrame = [self frameMinusKeyboard];
    self.publishView.frame = CGRectSetBottomCenter(self.composeView.frame.size.width/2, publishViewFrame.size.height-10, self.publishView.frame);
}

- (void) didStopRecording {
    [super didStopRecording];

    CGRect r = [self.graffitiView convertRect:self.publishView.frame fromView:self.composeView];
    [self.graffitiView addCutout:r];
    [self.publishView startAnimating];
}

- (void) willStartPreviewing {
    [super willStartPreviewing];
    [self.publishView stopAnimating];
}

@end
