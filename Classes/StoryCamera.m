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

    [self.composeView removeFromSuperview];

    self.viewportWidth = 100;
    self.viewportHeight = 100;
    self.cropToSquare = YES;
    self.controlsYoverlap = -20;

    return self;
}

- (void) configureButtons {
    [super configureButtons];
    self.cancelButton.hidden = self.isRecording && !self.recordingPaused;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void)setIsComposing:(BOOL)isComposing {
    [super setIsComposing:isComposing];
}

@end
