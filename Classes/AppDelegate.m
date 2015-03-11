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

    // THIS MUST HAPPEN BEFORE ACCESSING ANY COREDATA MODEL, as the AppViewController holds the managed object context.
    self.appController = [AppViewController sharedAppViewController];

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
    [self commonActivation:^{}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    [super applicationWillEnterForeground:application];

    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = self.appController;
         [self.window makeKeyAndVisible];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    PNLOG(@"application.did_enter_background");
    [super applicationDidEnterBackground:application];
    [self.snapchatTimer invalidate];
    self.snapchatTimer = nil;
    self.enteredBackgroundAt = [NSDate date];
    [Api sharedApi].fayeEnabled = NO;
    [Story prune];
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
    else if ([[UIApplication sharedApplication] canOpenURL:url]) {
        return [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [self commonActivation:^{}];
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

@end
