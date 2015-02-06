//
//  AppViewController.m
//  groups
//
//  Created by Jim Young on 11/26/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "AppViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Api.h"
#import "App.h"
#import "User.h"
#import "Story.h"
#import "WebViewController.h"
#import "GroupManager.h"
#import "StoryManager.h"
#import "Configuration.h"
#import "AlertView.h"
#import "UIImage+AnimatedGIF.h"
#import "PNUserPreferences.h"
#import "Directory.h"
#import "SavedApiRequest.h"
#import "SVProgressHUD.h"
#import "DefaultWelcomePanel.h"
#import "BlacklistedUsername.h"
#import "PushPermissionManager.h"
#import "AddressBookManager.h"

#import "DefaultNoobViewController.h"
#import "ContentImportObserver.h"
#import "NewMediaEditController.h"

@interface AppViewController ()

@property BOOL splashUponActivation;
@property (nonatomic, strong) UIImageView* logoView;
@property (nonatomic, strong) NSDate* lastSplashedAt;
@property (nonatomic, strong) UIView* coverView;
@property (nonatomic, strong) NSDate* enteredBackgroundAt;

@end

@implementation AppViewController

+ (AppViewController*)sharedAppViewController {
    return (AppViewController*)[self singleton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAppearance];

    self.view.backgroundColor = COLOR(whiteColor);
    self.mainController = [[MainCarouselController alloc] init];
    self.splashViewController = [[SplashViewController alloc] init];

    AFNetworkReachabilityManager* manager =[AFNetworkReachabilityManager sharedManager];
    __weak AppViewController* weakSelf = self;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [weakSelf setReachabilityStatus:status];
    }];
    [manager startMonitoring];

    self.reachabilityWarning = [[PNLabel alloc] initWithFrame:CGRectZero];
    self.reachabilityWarning.backgroundColor = [COLOR(redColor) colorWithAlphaComponent:0.88];
    self.reachabilityWarning.textColor = COLOR(whiteColor);
    self.reachabilityWarning.textAlignment = NSTextAlignmentCenter;
    self.reachabilityWarning.text = @"⚠️ No network connection ⚠️";
    self.reachabilityWarning.hidden = YES;
    [self.view addSubview:self.reachabilityWarning];

    [self addSplash];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect b = self.view.bounds;
    self.reachabilityWarning.frame = CGRectMake(0,20,b.size.width, 44);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.lastSplashedAt || ABS([self.lastSplashedAt timeIntervalSinceNow])>86400*7) { // Don't show splash more than once in a long time..
        [self showSplashWithDelay:1.0];
        self.lastSplashedAt = [NSDate date];
    }
}

- (void) resetUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_noobViewController resetUI];
        [_mainController resetUI];
        [self chooseCurrentController];
        [self openCamera];
    });
}

- (UIViewController*)noobViewController {
    if (!_noobViewController) {

        // Select one of several designs for the noob controller, based on configuration:
        NSString* noobControllerName = [Configuration stringFor:@"noob_controller"];

        if (noobControllerName) {
            Class noobClass = NSClassFromString([NSString stringWithFormat:@"%@NoobViewController", noobControllerName]);
            if (noobClass) {
                _noobViewController = [[noobClass alloc] init];
            }
        }

        if (!_noobViewController) _noobViewController = [DefaultNoobViewController new];
    }
    return _noobViewController;
}

- (void) chooseCurrentController {
    if ([Configuration shared]) {
        if ([App isLoggedIn]) {
            // Different transition
            if (self.currentViewController == self.splashViewController) {
                [self setCurrentViewController:self.mainController
                                    transition:UIViewAnimationOptionTransitionFlipFromLeft
                                      duration:1.0
                                withAnimations:nil
                                    completion:nil];
            }
            else {
                [self setCurrentViewController:self.mainController];
            }
        }
        else {
            [self setCurrentViewController:self.noobViewController];
        }
    }
    else {
        [self setCurrentViewController:self.splashViewController];
    }

    [self setNeedsStatusBarAppearanceUpdate];

}

#pragma mark override PNAppController defaults

// Override these to change the resource/file names.
- (NSString*) modelResourceName {
    return @"peanut";
}

- (NSString*) persistentStoreFilename {
    return @"peanut.sqlite";
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    return [super persistentStoreCoordinator];
}

- (void) didResetPersistentStore {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"emoticons_version"];
}

- (void) commonExit {
    [super commonExit];
    NSInteger count = [GroupManager manager].unreadCount + [StoryManager manager].unreadCount;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

// Open camera

- (void) openCamera {
    if ([App isLoggedIn]) {
        [self.mainController openCamera];
        [self.mainController.carousel setScrollEnabled:YES];
    }
}

- (void) jumpToCamera {
    if ([App isLoggedIn]) {
        [self.mainController.carousel scrollToItemAtIndex:2 animated:NO];
    }
}

- (void) openCameraForGroup:(Group*)group {
    if ([App isLoggedIn]) {
        if (group && !group.isMember) {
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/groups/join/%@", group.id]
                           parameters:nil
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.mainController openCameraForGroup:group];
                                 });
                             }];
        }
        else {
            [self.mainController openCameraForGroup:group];
        }
    }
}

// Navigate to group

- (void) openGroup:(Group*)group {
    if (!group) return;

    if ([App isLoggedIn]) {
        if (group.isGroupValue && !group.isMember) {
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/groups/join/%@", group.id]
                           parameters:nil
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 [self.mainController openGroup:group];
                             }];
        }
        else {
            [self.mainController openGroup:group];
        }
    }
}

- (void) openOverview {
    [self.mainController openInbox];
}

- (void) openFriends {
    [self.mainController openFriends];
}

- (void) openNewStories {
    [self.mainController openNewStories];
}

- (void) openProfileForUser:(User*)user {
    [self.mainController openProfileForUser:user];
}

- (void) openSettings {
    [self.mainController openSettings];
}

- (void) openPeople {
    [self.mainController openPeople];
}

- (void) openUnreadGroup {
    if ([UIApplication visibleKeyboardHeight] > 0) return; // don't switch if the keyboard is open.

    //    Group* unreadGroup = [[[GroupManager manager] unreadGroups] firstObject];
    Group* unreadGroup = [[[GroupManager manager] groups] firstObject];
    if (unreadGroup) {
        on_main(^{
            [self openGroup:unreadGroup];
        });
    }
}

- (void) importImage:(UIImage*)image withVideoUrl:(NSURL*)videoUrl andParams:(NSDictionary*)params {
//    [self.mainController openProfileForUser:[User me]];
    [self.mainController openCamera];

    NSLog(@"import %@ %@", image, videoUrl);

    NewMediaEditController* vc = [NewMediaEditController new];
    vc.photo = image;
    vc.videoUrl = videoUrl;
    vc.info = params;
    [self.mainController.cameraController presentViewController:vc animated:NO completion:nil];

}

// Checkin

- (void)checkinUsingFastApi:(BOOL)useFastApi callback:(void (^)(NSError* error))callback {

    Api *api = useFastApi ? [Api fastApi] : [Api sharedApi];

    [api postPath:@"/checkin"
       parameters:nil
         callback:^(NSSet *entities, id responseObject, NSError *error) {

             if (!error) self.didCheckIn = YES;

             PNLOG(@"checkin");
//           NSLog(@"checkin? %@", responseObject);

             [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateNotification object:nil userInfo:nil];

             on_main(^{
                 [self chooseCurrentController];

                 if (self.pendingPushOptions) {
                     [self emitCommandsForPushOptions:self.pendingPushOptions];
                     self.pendingPushOptions = nil;
                 }
             });

             if ([Configuration boolFor:@"fb_event_enable"]) {
                 // Facebook SDK sucks, so put it on background thread so it can't do as much damage
                 on_background(^{
                     [FBAppEvents activateApp];
                 });
             }

             // ==== Address book sync ====

                //AddressBookManager* ab = [AddressBookManager manager];
                //[ab syncCacheWithCompletion:^(BOOL success) {
                // NSLog(@"%d address book entries", ab.itemCount);
                //}];

             // ==== Blacklist ====
             NSManagedObjectContext* moc = [App privateManagedObjectContext];
             [moc performBlock:^{
                 NSArray *blacklist = [Configuration settingFor:@"blacklisted_usernames"];
                 if(blacklist) {
                     for (NSString *name in blacklist) {
                         BlacklistedUsername *b = [BlacklistedUsername findOrCreateById:name inContext:moc];
                         b.existsOnServerValue = YES;
                     }
                     [moc save:nil];
                 }
             }];

             // ====================

             if (callback) callback(error);
             if (error) return;
             if (![App isLoggedIn]) return;

             [User fetchFriendsWithCompletion:^(NSArray *userArray) {
                 NSLog(@"FRIENDS? %@", userArray);
             }];
             
             [[GroupManager manager] updateUnreadCount];
             [[ContentImportObserver shared] performObservation];

             [[GroupManager manager] refreshGroupsWithCompletion:^(NSSet *groups) {

                 void (^voidBlock)() = ^() {
                     [Api sharedApi].fayeEnabled = YES;

                     [[GroupManager manager] updateUnreadCount];

                     [[MediaUploadManager manager] retryUploadsWithLimit:100];

                     // If no existing stories (i.e., after login or signup), make them all viewed.
                     BOOL noStories = [[StoryManager manager] totalCount] == 0;
                     [[StoryManager manager] loadPublicFeedWithParams:nil
                                                  andCompletion:^(NSSet *stories) {
                                                      if (noStories) {
                                                          for (Story* story in stories) {
                                                              [story markViewed];
                                                          }
                                                          [(Story*)[stories anyObject] save];
                                                      }
                                                  }];

                     [[StoryManager manager] loadFriendFeedWithParams:nil
                                                        andCompletion:^(NSSet *stories) {
                                                            if (noStories) {
                                                                for (Story* story in stories) {
                                                                    [story markViewed];
                                                                }
                                                                [(Story*)[stories anyObject] save];
                                                            }
                                                        }];

                     [[PushPermissionManager manager] requestWithCompletion:nil];
                 };

                 // Look for groups with missing messages and load again if any
                 NSArray* groupsMissingMessages = [[groups allObjects] filteredArrayUsingBlock:^BOOL(Group* group, NSDictionary *bindings) {
                     return group.isMissingMessages;
                 }];

                 if (groupsMissingMessages.count) {
                     NSLog(@"loading convos again with last_seen_rank");
                     [[GroupManager manager] refreshGroupsWithCompletion:^(NSSet *groups) {
                         voidBlock();
                     }];
                 }
                 else
                     voidBlock();

             }];
         }];
}

- (void)setupAppearance {

    NSShadow* shadow = [NSShadow new];
    [shadow setShadowColor:nil];

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:FONT_B(20) forKey:NSFontAttributeName];
    [titleBarAttributes setValue:COLOR(navTitleColor) forKey:NSForegroundColorAttributeName];
    [titleBarAttributes setValue:shadow forKey:NSShadowAttributeName];
    [[UINavigationBar appearanceWhenContainedIn:[MainCarouselController class], nil] setTitleTextAttributes:titleBarAttributes];

    id appearance;

    appearance = [UIBarButtonItem appearanceWhenContainedIn:[MainCarouselController class], nil];

    NSDictionary* buttonBarTextAttributes = @{NSFontAttributeName:FONT_B(14),
                                              NSForegroundColorAttributeName:COLOR(whiteColor),
                                              NSShadowAttributeName:shadow};
    [appearance setTitleTextAttributes:buttonBarTextAttributes forState:UIControlStateNormal];
    [appearance setTintColor:COLOR(whiteColor)];

    buttonBarTextAttributes = @{NSFontAttributeName:FONT_B(14),
                                NSShadowAttributeName:shadow};
    [appearance setTitleTextAttributes:buttonBarTextAttributes forState:UIControlStateHighlighted];

    appearance = [FUISegmentedControl appearance];
    [appearance setCornerRadius:0.0f];
    [appearance setSelectedColor:COLOR(greenColor)];
    [appearance setDeselectedColor:COLOR(darkGrayColor)];
    [appearance setDividerColor:COLOR(whiteColor)];
    [appearance setSelectedFont:FONT_B(12)];
    [appearance setDeselectedFont:FONT_B(12)];
    [appearance setSelectedFontColor:COLOR(blackColor)];
    [appearance setDeselectedFontColor:COLOR(whiteColor)];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    }

    [SVProgressHUD setBackgroundColor:[COLOR(darkGrayColor) colorWithAlphaComponent:0.88]];
    [SVProgressHUD setForegroundColor:COLOR(whiteColor)];
}

#pragma mark Splash logo

- (void)addSplash {
    if (!self.logoView) {
        UIImage* image = [[UIImage imageNamed:@"splash-overlay"] imageByScalingProportionallyToFit:self.view.frame.size];
        self.logoView = [[UIImageView alloc] initWithImage:image];
        self.logoView.alpha = 1.0;
        self.logoView.contentMode = UIViewContentModeTop;
        self.logoView.frame = self.view.bounds;
        [self.view addSubview:self.logoView];
    }
}

- (void)showSplashWithDelay:(NSTimeInterval)delay {

    [self addSplash];
    [self.view bringSubviewToFront:self.logoView];

    [UIView animateWithDuration:1.0
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.logoView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.logoView removeFromSuperview];
                     }];
}


// Handle broadcast commands

- (void)handleCommandDictionary:(NSDictionary *)commandObject {

    NSLog(@"HANDLE COMMAND: %@", commandObject);
    NSString* source = commandObject[@"src"];

    NSString *instructionType = [commandObject valueForKeyPath:@"instruction"];
    if ([instructionType length] > 0) {

        if ([instructionType isEqualToString:@"group"]) {
            Group* group = nil;
            id group_id = [commandObject valueForKey:@"id"];

            if (group_id)
                group = [Group findById:group_id inContext:[App moc]];

            if (group)
                [self openGroup:group];
            else
                [[AppViewController sharedAppViewController] openOverview];

            [[GroupManager manager] refreshGroupsWithCompletion:nil];
            if ([source isEqualToString:@"widget"]) PNLOG(@"open_snap_from_widget");

        } else if ([instructionType isEqualToString:@"feed"]) {
            [[AppViewController sharedAppViewController] openNewStories];
            if ([source isEqualToString:@"widget"]) PNLOG(@"open_story_from_widget");

        } else if ([instructionType isEqualToString:@"user"]) {
            // TO DO: navigate directly to a specific user via URL

        } else if ([instructionType isEqualToString:@"invite"]) {
            id group_id = [commandObject valueForKey:@"id"];
            [App setPreference:@"invite_token" object:group_id];

        } else if ([instructionType isEqualToString:@"webview"] && [commandObject valueForKeyPath:@"url"]) {
            UINavigationController *nav = [WebViewController controllerInNavigationControllerWithURL:[NSURL URLWithString:[commandObject valueForKeyPath:@"url"]]];
            [self presentViewController:nav animated:YES completion:nil];

        } else if ([instructionType isEqualToString:@"open"] && ([commandObject valueForKeyPath:@"url"] || [commandObject valueForKeyPath:@"external_url"])) {
            [self saveContext];
            NSString* urlString = [commandObject valueForKeyPath:@"url"] ?: [commandObject valueForKeyPath:@"external_url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

        } else if ([instructionType isEqualToString:@"poke"]) {
            if ([commandObject valueForKey:@"url"]) {
                NSURL* url = [NSURL URLWithString:[commandObject valueForKey:@"url"]];
                PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:url.absoluteURL];
                [client postPath:url.path
                      parameters:nil
                         success:nil
                         failure:nil];
            }

        } else if ([instructionType isEqualToString:@"kline"]) {
            [[AppViewController singleton] commonExit];
            abort();

        } else if ([instructionType isEqualToString:@"badge"]) {
            if ([commandObject valueForKeyPath:@"tab"] || [commandObject valueForKeyPath:@"tab_number"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kAppBadgeNotification object:commandObject];
            } else {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[commandObject valueForKeyPath:@"value"] integerValue]];
            }
        }
    }
}

- (void) emitCommandsForPushOptions:(NSDictionary*)options {

    NSMutableDictionary* commandDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [commandDict addEntriesFromDictionary:options];

    if (options[@"stories"] || options[@"feed"])
        [commandDict setValue:@"feed" forKey:@"instruction"];

    if (options[@"snaps"])
        [commandDict setValue:@"group" forKey:@"instruction"];

    NSString *groupId = options[@"gid"] ?: options[@"oid"];
    if (groupId)
        [commandDict addEntriesFromDictionary:@{@"instruction":@"group", @"id":groupId}];

    if (commandDict[@"instruction"])
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppCommandNotification
                                                            object:commandDict
                                                          userInfo:nil];
}

// Reachability status
- (void)setReachabilityStatus:(AFNetworkReachabilityStatus)reachabilityStatus {
    _reachabilityStatus = reachabilityStatus;
    switch (reachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            self.reachabilityWarning.hidden = NO;
            [Api sharedApi].fayeEnabled = NO;
            [self.view bringSubviewToFront:self.reachabilityWarning];
            break;

        default:
            if (!self.reachabilityWarning.hidden) {
                self.reachabilityWarning.hidden = YES;
                [self checkinUsingFastApi:NO callback:^(NSError *error) {
                    if([App isLoggedIn])
                        [Api sharedApi].fayeEnabled = YES;
                }];
            }
            else {
                self.reachabilityWarning.hidden = YES;
            }
            break;
    }
}

- (void)didEnterBackground {
    if (!self.coverView) {
        self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.coverView.backgroundColor = COLOR(blackColor);
        [self.view addSubview:self.coverView];
    }

    self.enteredBackgroundAt = [NSDate date];
    self.coverView.hidden = NO;
}

- (void)didBecomeActive {
    self.coverView.hidden = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.currentViewController.preferredStatusBarStyle;
}

-(BOOL)prefersStatusBarHidden {
    return ([App isLoggedIn]) ? self.currentViewController.prefersStatusBarHidden : YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return self.currentViewController.supportedInterfaceOrientations;
    //    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
