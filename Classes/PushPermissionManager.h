//
//  PushPermissionManager.h
//  SnapCracklePop
//
//  Created by Jim Young on 6/15/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushPermissionManager : NSObject

@property (nonatomic, strong) NSData* deviceToken;

+ (instancetype) manager;
- (void)requestWithCompletion:(void (^)(NSData* token))completion;

// The app delegate must call these:
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

@end