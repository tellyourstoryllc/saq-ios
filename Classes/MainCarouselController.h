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
@class PeopleViewController;
@class MeViewController;
@class FriendViewController;
@class PamphletViewController;

@interface MainCarouselController : PNCarouselViewController {
    SystemSoundID receiveSoundID;
    SystemSoundID mentionSoundID;
}

@property (nonatomic, strong) PeopleViewController* peopleController;
@property (nonatomic, strong) MeViewController* myStoryController;
@property (nonatomic, strong) PamphletViewController* pamphletController;
@property (nonatomic, strong) InboxViewController* inboxController;

- (void) resetUI;

- (void) openPeople;
- (void) openMyStory;
- (void) openInbox;

- (void) openGroup:(Group*)group;
- (void) openSettings;

- (Group*) currentGroup;

- (UIPanGestureRecognizer*) panGestureRecognizer;

- (void) setScrollEnabled:(BOOL)enabled;

@end