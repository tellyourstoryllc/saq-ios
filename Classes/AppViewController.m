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
#import "BlacklistedUsername.h"
#import "PushPermissionManager.h"
#import "AddressBookManager.h"

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
    [_mainController resetUI];
    [self chooseCurrentController];
}

- (void) chooseCurrentController {
    if ([Configuration shared]) {
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

- (void) openSettings {
    [self.mainController openSettings];
}

- (void) openPeople {
    [self.mainController openPeople];
}

- (void) openMyStory {
    [self.mainController openMyStory];
}

// Checkin

- (void)checkinUsingFastApi:(BOOL)useFastApi callback:(void (^)(NSError* error))callback {

    Api *api = useFastApi ? [Api fastApi] : [Api sharedApi];
    [api postPath:@"/checkin"
       parameters:nil
         callback:[api authCallbackWithCompletion:^(NSSet *entities, id responseObject, NSError *error, BOOL authorized) {

        NSLog(@"CHECKIN: %@", responseObject);

        if (!error) self.didCheckIn = YES;

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

        if (callback) callback(error);
        if (error) return;

        [Api sharedApi].fayeEnabled = NO;

        [[MediaUploadManager manager] retryUploadsWithLimit:100];

        [[StoryManager manager] loadPublicFeedWithParams:nil
                                           andCompletion:^(NSSet *stories) {
                                           }];

        if ([App isLoggedIn])
            [[PushPermissionManager manager] requestWithCompletion:nil];

        //             [[GroupManager manager] refreshGroupsWithCompletion:^(NSSet *groups) {
        //                 // Look for groups with missing messages and load again if any
        //                 NSArray* groupsMissingMessages = [[groups allObjects] filteredArrayUsingBlock:^BOOL(Group* group, NSDictionary *bindings) {
        //                     return group.isMissingMessages;
        //                 }];
        //
        //                 if (groupsMissingMessages.count) {
        //                     [[GroupManager manager] refreshGroupsWithCompletion:nil];
        //                 }
        //             }];
        
    }]
     ];
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
                                              NSForegroundColorAttributeName:COLOR(darkGrayColor),
                                              NSShadowAttributeName:shadow};
    [appearance setTitleTextAttributes:buttonBarTextAttributes forState:UIControlStateNormal];
    [appearance setTintColor:COLOR(darkGrayColor)];

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

            [[GroupManager manager] refreshGroupsWithCompletion:nil];
            if ([source isEqualToString:@"widget"]) PNLOG(@"open_snap_from_widget");

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
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return self.currentViewController.supportedInterfaceOrientations;
    //    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
