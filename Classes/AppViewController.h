//
//  AppViewController.h
//  groups
//
//  Created by Jim Young on 11/26/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "PNAppController.h"
#import "MainCarouselController.h"
#import "SplashViewController.h"
#import "CenterViewController.h"
#import "NoobControllerProtocol.h"
#import "AFNetworkReachabilityManager.h"

@interface AppViewController : PNAppController

@property (nonatomic, strong) UIViewController <NoobControllerProtocol> *noobViewController;
@property (nonatomic, strong) MainCarouselController* mainController;
@property (nonatomic, strong) SplashViewController* splashViewController;

@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, strong) PNLabel* reachabilityWarning;

@property (nonatomic, assign) BOOL didCheckIn;
@property (nonatomic, strong) NSDictionary* pendingPushOptions;

+ (AppViewController*)sharedAppViewController;

- (void) resetUI;

- (void) openCameraForGroup:(Group*)group;
- (void) openCamera;
- (void) jumpToCamera; // Like openCamera, but w/o animation

- (void) openGroup:(Group*)group;
- (void) openUnreadGroup;

- (void) openOverview;

- (void) openProfileForUser:(User*)user;
- (void) openFriends;
- (void) openNewStories;

- (void) openSettings;
- (void) openPeople;

- (void) importImage:(UIImage*)image withVideoUrl:(NSURL*)videoUrl andParams:(NSDictionary*)params;

- (void) checkinUsingFastApi:(BOOL)useFastApi callback:(void (^)(NSError* error))callback;

- (void) emitCommandsForPushOptions:(NSDictionary*)options;

@end