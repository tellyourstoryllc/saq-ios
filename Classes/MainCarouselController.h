//
//  MainCarouselController.h
//  SnapCracklePop
//
//  Created by Jim Young on 8/2/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PNCarouselViewController.h"
#import "Group.h"
#import <AudioToolbox/AudioToolbox.h>

@class InboxViewController;
@class CenterViewController;
@class PeopleViewController;
@class MyStoryViewController;
@class FriendViewController;

@interface MainCarouselController : PNCarouselViewController {
    SystemSoundID receiveSoundID;
    SystemSoundID mentionSoundID;
}

@property (nonatomic, strong) InboxViewController* inboxController;
@property (nonatomic, strong) CenterViewController* cameraController;
@property (nonatomic, strong) PeopleViewController* peopleController;
@property (nonatomic, strong) MyStoryViewController* myStoryController;
@property (nonatomic, strong) FriendViewController* friendController;

- (void) resetUI;

- (void) openPeople;
- (void) openFriends;
- (void) openMyStory;
- (void) openInbox;

- (void) openProfileForUser:(User*)user;
- (void) openNewStories;

- (void) openCameraForGroup:(Group*)group;
- (void) openCamera;
- (void) closeCamera;

- (void) openGroup:(Group*)group;
- (void) openSettings;

- (User*) currentProfileUser;
- (Group*) currentGroup;

- (UIPanGestureRecognizer*) panGestureRecognizer;

@end