//
//  App.h
//  chat
//
//  Created by Cragin Godley on 10/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AFNetworking.h"

#define kWillClearDataNotification @"kWillClearDataNotification"
#define kDidClearDataNotification @"kDidClearDataNotification"

#define kSimultaneousVideoLimit     2

@interface App : NSObject
+(BOOL) isLoggedIn;
+(NSManagedObjectContext*) rootObjectContext;
+(NSManagedObjectContext*) managedObjectContext;
+(NSManagedObjectContext*) privateManagedObjectContext;

/* Just an alias for managedObjectContext */
+(NSManagedObjectContext*) moc;

+ (void) logout;
+ (void) clearUser;
+ (void) setPreference:(NSString *)key object:(id)value;
+ (AppDelegate*) sharedDelegate;
+ (NSString*) getStringPreference:(NSString *)key;
+ (NSString*)userId;
+ (NSString*)username;
+ (NSString*)myMentionName;
+ (NSString*)token;

+ (AFNetworkReachabilityStatus) reachabilityStatus;

+ (NSString*)storedPasswordForUsername:(NSString*)username;
+ (void)storePassword:(NSString*)password forUsername:(NSString*)username;

+ (BOOL)isCrappyDevice;
+ (int)simulatanenousVideoLimit;

@end