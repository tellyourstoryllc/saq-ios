//
//  MainCamcorder.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "MainCamera.h"

#import "PNUserPreferences.h"
#import "ArrowBox.h"

@implementation MainCamera

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.leftArrowButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,40)];
    self.leftArrowButton.buttonColor = COLOR(whiteColor);
    [self.controlsView addSubview:self.leftArrowButton];

    self.rightArrowButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,60,40)];
    self.rightArrowButton.buttonColor = COLOR(whiteColor);
    [self.controlsView addSubview:self.rightArrowButton];

    self.unreadMessages = [[UnreadMessageIndicator alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.unreadMessages.layer.cornerRadius = 20;
    self.unreadMessages.userInteractionEnabled = YES;
    [self.cameraView addSubview:self.unreadMessages];

    self.friendRequests = [[FriendRequestIndicator alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.friendRequests.layer.cornerRadius = 20;
    self.friendRequests.userInteractionEnabled = YES;
    [self.cameraView addSubview:self.friendRequests];

    ArrowBox* arrow = [[ArrowBox alloc] initWithFrame:self.leftArrowButton.bounds];
    arrow.arrowColor = [UIColor blackColor];
    arrow.rightArrowWidth = -10;
    arrow.leftArrowWidth = 0;
    [self.leftArrowButton maskWithView:arrow];

    ArrowBox* arrow2 = [[ArrowBox alloc] initWithFrame:self.rightArrowButton.bounds];
    arrow2.arrowColor = [UIColor blackColor];
    arrow2.rightArrowWidth = 0;
    arrow2.leftArrowWidth = -10;
    [self.rightArrowButton maskWithView:arrow2];

    self.leftArrowButton.alpha = 0.5;
    self.rightArrowButton.alpha = 0.5;

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    self.stopRecordingButton.frame = CGRectSetMiddleRight(self.bounds.size.width, self.recordButton.center.y, self.stopRecordingButton.frame);

    self.leftArrowButton.frame = CGRectSetMiddleLeft(0, CGRectGetMidY(self.recordButton.frame), self.leftArrowButton.frame);
    self.rightArrowButton.frame = CGRectSetMiddleRight(self.bounds.size.width, CGRectGetMidY(self.recordButton.frame), self.rightArrowButton.frame);

    self.unreadMessages.frame = CGRectSetMiddleRight(CGRectGetMinX(self.swapCameraButton.frame)-10, CGRectGetMidY(self.swapCameraButton.frame), self.unreadMessages.frame);
    self.friendRequests.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.flashlightButton.frame)+10, CGRectGetMidY(self.flashlightButton.frame), self.unreadMessages.frame);

}

- (void) configureButtons {
    [super configureButtons];

    BOOL recordedSomething = self.isRecording && self.recordingDuration > 0.1;

    self.cancelButton.hidden = !recordedSomething;

    self.leftArrowButton.hidden = recordedSomething;
    self.rightArrowButton.hidden = recordedSomething;

    self.unreadMessages.hidden = self.leftArrowButton.hidden || self.isComposing;
    self.friendRequests.hidden = self.rightArrowButton.hidden || self.isComposing;
}

- (void)startVineRecording {
    [super startVineRecording];
    self.carousel.scrollEnabled = NO;
}

- (void)stopRecording {
    [super stopRecording];
    self.carousel.scrollEnabled = YES;
}

- (void)abortRecording {
    [super abortRecording];
    self.carousel.scrollEnabled = YES;
}

@end
