//
//  PushPermissionManager.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
#import "PushPermissionManager.h"
#import "PNUIAlertView.h"
#import "PNUserPreferences.h"
#import "Api.h"

typedef void(^PushPermissionCallback)(NSData* token);

@interface PushPermissionManager()
@property (nonatomic, assign) BOOL skipAlert;
@property (nonatomic, strong) NSMutableArray* callbacks;
@end

@implementation PushPermissionManager

+ (instancetype)manager {

    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)requestWithCompletion:(void (^)(NSData* token))completion {

    if (!self.callbacks)
        self.callbacks = [NSMutableArray new];

    if (completion) {
        [self.callbacks addObject:[completion copy]];
    }
    else {
        PushPermissionCallback dummyBlock = ^(NSData* data) { return; };
        [self.callbacks addObject:[dummyBlock copy]];
    };

    if (self.callbacks.count > 1) {
        return;
    }

    void (^registerBlock)() = ^() {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];

        else if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types])
            [[UIApplication sharedApplication] registerForRemoteNotifications];

        else {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        }
    };

    if (![[PNUserPreferences shared] boolPreference:@"didRegisterForNotifications" orDefault:NO] && ![Configuration boolFor:@"has_push_token"]) {

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types]) {
                self.skipAlert = YES;
            }
        }

        if (!self.skipAlert) {
            self.skipAlert = YES;

            NSString* permissionRequestTitle = @"Allow Push Notifications";
            NSString* permissionRequestMessage = [NSString stringWithFormat:@"Please allow notifications so you can be notified of new snaps and stories."];

            PNUIAlertView* alert = [[PNUIAlertView alloc] initWithTitle:permissionRequestTitle
                                                                message:permissionRequestMessage
                                                         andButtonArray:@[@"OK"]];

            [alert showWithCompletion:^(NSInteger buttonIndex) {
                registerBlock();
            }];
        }
        else {
            registerBlock();
        }
    }
    else if (!self.deviceToken) {
        registerBlock();
    }
    else {
        [self performCallback:self.deviceToken];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PNUserPreferences shared] setPreference:@"didRegisterForNotifications" boolValue:YES];
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    self.deviceToken = deviceToken;
    BOOL hasPushes;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        hasPushes = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert);
    else
        hasPushes = ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] &&
                     ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] & UIUserNotificationTypeAlert));

    [[Api sharedApi] postPath:@"/ios_device_preferences/update"
                   parameters:@{@"server_pushes_enabled":(hasPushes ? @"true" : @"false")}
                     callback:nil];

    [self performCallback:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PNUserPreferences shared] setPreference:@"didRegisterForNotifications" boolValue:YES];
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
    [self performCallback:nil];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[PNUserPreferences shared] setPreference:@"didRegisterForNotifications" boolValue:YES];
    NSLog(@"didRegisterForNotifications");
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)didEnterBackground {
    self.skipAlert = NO;
}

- (void)performCallback:(NSData*)token {

    NSArray* callbacks = self.callbacks;
    self.callbacks = nil;

    for (PushPermissionCallback callback in callbacks) {
        callback(token);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
