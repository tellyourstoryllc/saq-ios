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
#import "AFNetworkReachabilityManager.h"

@interface AppViewController : PNAppController

@property (nonatomic, strong) MainCarouselController* mainController;
@property (nonatomic, strong) SplashViewController* splashViewController;

@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, strong) PNLabel* reachabilityWarning;

@property (nonatomic, assign) BOOL didCheckIn;
@property (nonatomic, strong) NSDictionary* pendingPushOptions;

+ (AppViewController*)sharedAppViewController;

- (void) resetUI;
- (void) setCarouselEnabled:(BOOL)enabled;

- (void) openMyStory;
- (void) openPeople;
- (void) openGroup:(Group*)group;
- (void) openSettings;

- (void) checkinUsingFastApi:(BOOL)useFastApi callback:(void (^)(NSError* error))callback;
- (void) emitCommandsForPushOptions:(NSDictionary*)options;


@end