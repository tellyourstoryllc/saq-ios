//
//  AppDelegate.m
//  chat
//
//  Created by Cragin Godley on 10/4/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "AppDelegate.h"
#import <RHAddressBook.h>
#import <RHAddressBookSharedServices.h>
#import <FacebookSDK/FacebookSDK.h>
#import <EGOCache.h>
#import <SDImageCache.h>

#import "NSData+Base64.h"
#import "Api.h"
#import "App.h"
#import "Configuration.h"
#import "AppViewController.h"
#import "PNUserPreferences.h"

#import "TestFlight.h"
#import "Flurry.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SVProgressHUD.h"
#import "PNProgress.h"
#import "SkyMessage.h"
#import "PushPermissionManager.h"

#import "GroupManager.h"
#import "StoryManager.h"

#import "Contact.h"
#import "Directory.h"
#import "AlertView.h"
#import "PNUIAlertView.h"
#import "StatusView.h"
#import "Story.h"

#import "DefaultWelcomePanel.h"
#import "PNLogger.h"
#import "UserReviewPrompter.h"

#import "ExtensionConduit.h"

#import "WorldPopulationCounter.h"

#define kDefaultForegroundFetchInterval 120 // seconds

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"UGH" exception:exception];
}

@interface AppDelegate()

@property (nonatomic, strong) NSDate* enteredBackgroundAt;
@property (nonatomic, strong) NSTimer* snapchatTimer;
@property (nonatomic, assign) BOOL commonActivationDisabled;

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions: %@", launchOptions);

    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    NSLog(@"enabling background fetches");

    NSLog(@"directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

#if DEBUG
    [Flurry setCrashReportingEnabled:NO];
#else
    [Flurry setSecureTransportEnabled:YES];
    [Flurry setCrashReportingEnabled:YES];
    // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif
    [Flurry setBackgroundSessionEnabled:YES];

    [Flurry startSession:kFlurryAPIKey];
    [TestFlight takeOff:kTestflightKey];

    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState]) {
        PNLOG(@"launch.background");
    }
    else {
        PNLOG(@"launch");
    }

    // THIS MUST HAPPEN BEFORE ACCESSING ANY COREDATA MODEL, as the AppViewController holds the managed object context.
    self.appController = [AppViewController sharedAppViewController];

    // Don't show Welcome/Invite screens for already-logged-in users
    BOOL completed_welcome_migration = [[PNUserPreferences shared] boolPreference:@"completed_welcome_migration"];
    if(!completed_welcome_migration && [App isLoggedIn]) {
        [[PNUserPreferences shared] setPreference:@"welcome_completed" boolValue:YES];
        [[PNUserPreferences shared] setPreference:@"invite_decided" boolValue:YES];
    }
    [[PNUserPreferences shared] setPreference:@"completed_welcome_migration" boolValue:YES];

    // Must initialize GroupManager before any network requests
    [GroupManager manager];
    [StoryManager manager];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    if (UIApplicationStateBackground != [[UIApplication sharedApplication] applicationState]) {
        [self applicationWillEnterForeground:application];
    }

    [[EGOCache globalCache] setDefaultTimeoutInterval:86400*365];

    // Save push notification options for processing later, after checkin and setting up the views.
    // See checkinUsingFastApi:callback: in AppViewController.
    NSDictionary* remoteNotificationOptions = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    NSDictionary* localNotificationOptions = [launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo];

    AppViewController* avc = [AppViewController sharedAppViewController];
    if ([remoteNotificationOptions count])
        avc.pendingPushOptions = remoteNotificationOptions;
    else if ([localNotificationOptions count])
        avc.pendingPushOptions = localNotificationOptions;

    /* Print out names of available fonts */

    //    NSMutableArray* fontNames = [NSMutableArray arrayWithCapacity:32];
    //    for (NSString* family in [UIFont familyNames])
    //    {
    //        for (NSString* name in [UIFont fontNamesForFamilyName: family])
    //        {
    //            [fontNames addObject:name];
    //        }
    //    }
    //    [fontNames sortUsingComparator:^NSComparisonResult(NSString* a, NSString* b) {
    //        return [a compare:b];
    //    }];
    //    ins([fontNames componentsJoinedByString:@", "]);

    //    NSManagedObjectContext* c = [App privateManagedObjectContext];
    //    NSLog(@"users: %d", [User countUsingPredicate:nil inContext:c]);

    NSArray* groups = [Group findAllUsingPredicate:nil inContext:[App moc]];
    for (Group* g in groups) {
        NSLog(@"g, %@ %@ %@ %@", g.id, g.messages, g.last_message_at, g.last_received_message_at);
        for (id obj in g.messages) {
            NSLog(@"MSG: %@", obj);
        }
    }

    return YES;
}

- (void)commonActivation:(void (^)())activity {
    if (!self.commonActivationDisabled) {
        self.commonActivationDisabled = YES;
        activity();
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    [PNProgress dismiss];
    [[App managedObjectContext] saveToRootWithCompletion:^(BOOL success, NSError *err) {
        NSLog(@"App.managedObjectContext saved to root");
    }];

    // Log background status.
    UIBackgroundRefreshStatus bgStatus = [[UIApplication sharedApplication] backgroundRefreshStatus];
    switch (bgStatus) {
        case UIBackgroundRefreshStatusRestricted:
            PNLOG(@"backgroundStatus.restricted");
            break;

        case UIBackgroundRefreshStatusDenied:
            PNLOG(@"backgroundStatus.denied");
            break;

        case UIBackgroundRefreshStatusAvailable:
            PNLOG(@"backgroundStatus.available");
            break;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");

    if (![App isLoggedIn]) return;

    [self commonActivation:^{
        if ([self.enteredBackgroundAt timeIntervalSinceNow] < -6) {
            [[AppViewController sharedAppViewController] jumpToCamera];
        }
    }];

    // Check to see if widgets have been installed
    PNUserPreferences* prefs = [PNUserPreferences shared];
    ExtensionConduit* cache = [ExtensionConduit shared];
    [cache reloadCacheInfo];
    if (![prefs boolPreference:@"story_widget_installed"] && [cache objectForKey:@"story_widget_updated_at"]) {
        [prefs setPreference:@"story_widget_installed" boolValue:YES];
        PNLOG(@"story_widget_installed");
    }
    if (![prefs boolPreference:@"snap_widget_installed"] && [cache objectForKey:@"snap_widget_updated_at"]) {
        [prefs setPreference:@"snap_widget_installed" boolValue:YES];
        PNLOG(@"snap_widget_installed");
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    [super applicationWillEnterForeground:application];

    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = self.appController;
        [[AppViewController sharedAppViewController] resetUI];
        [self.window makeKeyAndVisible];
    }

    float delay = [App isLoggedIn] ? 2.0 : 0.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

                       // Rate limit.. don't checkin more than once every 30 seconds.
                       // apply only when opening app. (login needs to do it twice in succession)
                       static NSDate* lastCheckin;
                       if (lastCheckin && ([lastCheckin timeIntervalSinceNow] > -1.0*30)) {
                           NSLog(@"checkin rate limited. skipping");
                           return;
                       }
                       lastCheckin = [NSDate date];
                       [[AppViewController sharedAppViewController] checkinUsingFastApi:NO callback:nil];
                   });

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // If we call this immediately then the dialog doesn't appear, so wait
//        [[UserReviewPrompter prompter] run];
//    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    PNLOG(@"application.did_enter_background");
    [super applicationDidEnterBackground:application];
    [self.snapchatTimer invalidate];
    self.snapchatTimer = nil;
    self.enteredBackgroundAt = [NSDate date];
    [Api sharedApi].fayeEnabled = NO;
    [SkyMessage prunePlaceholders];
    [[SDImageCache sharedImageCache] clearMemory];
    [Flurry pauseBackgroundSession];
    self.commonActivationDisabled = NO;

    // For TESTING purposes ONLY:
    //    NSArray* stories = [SnapchatStory findAllUsingPredicate:nil inContext:[App moc]];
    //        for (SnapchatStory* s in stories) {
    //            [s.managedObjectContext performBlock:^{
    //                s.isNewValue = YES;
    //                [s save];
    //                ins(s);
    //            }];
    //        }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    PNLOG(@"application.terminate");
    [super applicationWillTerminate:application];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[App managedObjectContext] saveToRootWithCompletion:^(BOOL success, NSError *err) {
        NSLog(@"Memory warning! App.managedObjectContext saved to root");
    }];
}

// How to generate a push cert:
// openssl pkcs12 -nodes -clcerts -in FILENAME.p12 -out FILENAME.pem

// How to send push from SCP console:
// user.mobile_notifier.create_ios_notifications('hi', {foo: 'bar'})

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Got push token: %@", deviceToken);

    [[PushPermissionManager manager] application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];

    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];

    for (int i = 0; i < [deviceToken length]; i++)
        [token appendFormat:@"%02.2hhx", data[i]];

    [[Api sharedApi] postPath:@"/ios/apn/set" withParameters:@{@"push_token" : token} andCallback:nil];

    static BOOL displayedNotificationWarning;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0 && !displayedNotificationWarning) {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types == UIRemoteNotificationTypeNone) {
            PNLOG(@"apn.register.success.muted");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications Disabled"
                                                            message:[NSString stringWithFormat:@"Go to your device's Settings > Notification Center > enable %@ to ensure you receive messages", kAppTitle]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            displayedNotificationWarning = YES;
        }
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"FAILED TO REGISTER FOR APN- are you using the correct provisioning profile?");
    [[PushPermissionManager manager] application:app didFailToRegisterForRemoteNotificationsWithError:err];

    [[Api sharedApi] postPath:@"/ios/apn/reset" withParameters:nil andCallback:nil];
    PNLOG(@"apn.register.fail");
}

- (void)application:(UIApplication *)app didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"didRegisterUserNotificationSettings: %@", notificationSettings);
    [[PushPermissionManager manager] application:app didRegisterUserNotificationSettings:notificationSettings];
}

// Remote commands may be encoded in URLs. E.g., "peanut://opcode/key1/value1/key2/value2/..."
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    if ([url.scheme isMatchedByRegex:@"fb"]) {
        [self commonActivation:^{}];
        return [FBSession.activeSession handleOpenURL:url];

    } else if ([url.scheme isMatchedByRegex:@"http(s)?"]) {
        [self commonActivation:^{}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppCommandNotification
                                                            object:@{@"instruction":@"webview", @"url":url.absoluteString}
                                                          userInfo:nil];
        return YES;

    } else if ([super application:application openURL:url sourceApplication:sourceApplication annotation:annotation]) {
        // this disables activation activities if command was detected.
        [self commonActivation:^{}];
        return YES;
    }
    else {
        [self commonActivation:^{
            if ([self.enteredBackgroundAt timeIntervalSinceNow] < -6) {
                [[AppViewController sharedAppViewController] jumpToCamera];
            }
        }];
        return NO;
    }
}

-(void)commonRemoteNotificationHandler:(NSDictionary*)userInfo {

    PNLOG(@"apn.received");
    
    // For debugging push payloads.
    //    if (userInfo)
    //        [AlertView showWithMessage:[NSString stringWithFormat:@"%@", userInfo]];

    // User tapped on notification
    if(UIApplicationStateInactive == [UIApplication sharedApplication].applicationState) {
        PNLOG(@"apn.received.opened");
        [self handlePushNotificationOptions:userInfo];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self commonRemoteNotificationHandler:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {

    PNLOG(@"apn.fetch.push_received");

    [self commonRemoteNotificationHandler:userInfo];

    if (userInfo[@"aps"][@"content-available"] &&
        (UIApplicationStateBackground == [UIApplication sharedApplication].applicationState)) {

        if(![App isLoggedIn]) {
            PNLOG(@"apn.fetch.logged_out");
            handler(UIBackgroundFetchResultNoData);
            return;
        }

        // Check rate limit
        NSDate* lastExecution = [[PNUserPreferences shared] datePreference:@"last_fetch_started_at"];
        NSUInteger rateLimit = 60;
        if (lastExecution && ([lastExecution timeIntervalSinceNow] > -1.0*rateLimit)) {
            PNLOG(@"apn.fetch.rate_limited");
            handler(UIBackgroundFetchResultNoData);
            return;
        }

        PNLOG(@"apn.fetch.start");

        [[PNUserPreferences shared] setPreference:@"last_fetch_started_at" dateValue:[NSDate date]];
        BOOL shouldDownload = [Configuration boolFor:@"push_download_media"];
        BOOL shouldUpload = [Configuration boolFor:@"push_upload_media"];

        if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi] && [Configuration boolFor:@"push_load_wifi_only"]) {
            shouldDownload = NO;
            shouldUpload = NO;
        }

        NSNumber* limit = [Configuration settingFor:@"remote_story_limit"] ?: @(25);

        [[GroupManager manager] refreshGroupsWithCompletion:^(NSSet *groups) {
            [[StoryManager manager] loadFriendFeedWithParams:@{@"limit":limit}
                                         andCompletion:^(NSSet *stories) {
                                             handler(UIBackgroundFetchResultNewData);
                                         }];
        }];
    }
    else
        handler(UIBackgroundFetchResultNewData);

}

-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    static BOOL isShowingAlert;
    NSLog(@"didReceiveLocalNotification: %@", notification);

    if (notification.userInfo) {
        NSNumber *showInForeground = [notification.userInfo valueForKey:@"showInForeground"];
        NSString* alertTitle = [Configuration stringFor:@"local_notification_title"] ?: @"Warning";
        if(!isShowingAlert && showInForeground != nil && [showInForeground boolValue])
        {
            isShowingAlert = YES;
            PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:alertTitle andMessage:notification.alertBody];
            [alert showWithCompletion:^(NSInteger buttonIndex) {
                isShowingAlert = NO;
            }];
        }

        // User tapped on notification
        if(UIApplicationStateInactive == [UIApplication sharedApplication].applicationState) {
            PNLOG(@"apn.received.opened");
            [self handlePushNotificationOptions:notification.userInfo];
        }
    }
}

-(void)handlePushNotificationOptions:(NSDictionary*)options {
    [self commonActivation:^{
        [[AppViewController sharedAppViewController] emitCommandsForPushOptions:options];
    }];
}

- (BOOL)isCommandScheme:(NSString*)scheme {
    return ([scheme isMatchedByRegex:kCustomURLScheme] || [scheme isMatchedByRegex:@"peanut"]);
}

#pragma mark Fetching messages from Snapchat

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    PNLOG(@"backgroundFetch.launch");

    if(![App isLoggedIn]) {
        PNLOG(@"backgroundFetch.skip.logged_out");
        [Flurry pauseBackgroundSession];
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }

    NSDate* lastExecution = [[PNUserPreferences shared] datePreference:@"last_fetch_started_at"];
    NSUInteger rateLimit = 60;
#ifdef DEBUG
    rateLimit = 0;
#endif

    if (lastExecution && ([lastExecution timeIntervalSinceNow] > -1.0*rateLimit)) {
        PNLOG(@"backgroundFetch.rate_limited");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }

    PNLOG(@"backgroundFetch.start");

    NSDate *fetch_start_time = [NSDate date];
    [[PNUserPreferences shared] setPreference:@"last_fetch_started_at" dateValue:[NSDate date]];
    BOOL shouldDownload = [Configuration boolFor:@"background_download_media"];
    BOOL shouldUpload = [Configuration boolFor:@"background_upload_media"];

    if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi] && [Configuration boolFor:@"background_load_wifi_only"]) {
        shouldDownload = NO;
        shouldUpload = NO;
    }

    NSLog(@"fetchSnapUp.appdelegate download:%d upload:%d", shouldDownload, shouldUpload);

    [[GroupManager manager] refreshGroupsWithCompletion:^(NSSet *groups) {
        [[StoryManager manager] loadFriendFeedWithParams:@{@"limit":@(25)}
                                     andCompletion:^(NSSet *stories) {
                                         completionHandler(stories.count+groups.count ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData);
                                     }];
    }];
}

@end
