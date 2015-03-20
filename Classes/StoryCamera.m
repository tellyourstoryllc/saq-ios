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

@property (strong) PNLabel* recordLabel;

@end

@implementation StoryCamera

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self.composeView removeFromSuperview];

    self.viewportWidth = 100;
    self.viewportHeight = 100;
    self.cropToSquare = YES;
    self.controlsYoverlap = -20;

    self.recordLabel = [[PNLabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    self.recordLabel.textAlignment = NSTextAlignmentCenter;
    self.recordLabel.font = FONT_B(18);
    self.recordLabel.text = @"RECORD";
    [self.controlsView addSubview:self.recordLabel];

    __weak StoryCamera* weakSelf = self;
    [self setRecordingProgressBlock:^(NSTimeInterval time, CGFloat progress) {
        NSUInteger minutes = (int)time / 60;
        NSUInteger seconds = (int)time % 60;
        weakSelf.recordLabel.text = [NSString stringWithFormat:@"%i:%02i", minutes, seconds];
        weakSelf.recordLabel.textColor = (time+15.0 > weakSelf.maxRecordingDuration) ? COLOR(redColor) : [UIColor blackColor];
    }];
    
    return self;
}

- (void) configureButtons {
    [super configureButtons];
    self.cancelButton.hidden = self.isRecording && !self.recordingPaused;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.recordLabel.frame = CGRectSetTopCenter(CGRectGetMidX(self.recordButton.frame),
                                                 CGRectGetMaxY(self.recordButton.frame),
                                                 self.recordLabel.frame);
}

- (void)setIsComposing:(BOOL)isComposing {
    [super setIsComposing:isComposing];
}

- (void)didStopRecording {
    [super didStopRecording];
    self.recordLabel.text = nil;
}

@end
