//
//  MainCamcorder.h
//  SnapCracklePop
//
//  Created by Jim Young on 10/16/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryCamera.h"
#import "UnreadMessageIndicator.h"
#import "FriendRequestIndicator.h"
#import "TutorialBubble.h"

@interface MainCamera : StoryCamera

@property (nonatomic, strong) PNButton *leftArrowButton;
@property (nonatomic, strong) PNButton *rightArrowButton;
@property (nonatomic, strong) UnreadMessageIndicator* unreadMessages;
@property (nonatomic, strong) FriendRequestIndicator* friendRequests;

@property (nonatomic, assign) UIViewController* controller;
@property (nonatomic, assign) iCarousel* carousel;

@end
