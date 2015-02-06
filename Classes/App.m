//
//  App.m
//  chat
//
//  Created by Cragin Godley on 10/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "App.h"
#import "Api.h"
#import "AppViewController.h"
#import "PNSnapchatAPI.h"
#import "PNUserPreferences.h"
#import "AppDelegate.h"
#import "JSONProcessor.h"

#import "SVProgressHUD.h"

#import "User.h"
#import "Group.h"
#import "SkyMessage.h"
#import "Story.h"
#import "Emoticon.h"
#import "StatusView.h"
#import "UserPreference.h"
#import "IosPreference.h"
#import "SkyAccount.h"
#import "UserGroupPreference.h"
#import "SavedApiRequest.h"
#import "AddressBookManager.h"
#import "ExtensionConduit.h"

@implementation App

+(AppDelegate*)sharedDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

+(BOOL)isLoggedIn {
    BOOL authenticated = [self token] != nil;
    return authenticated && [self userId] != nil;
}

+(void) logout {

    [[Api sharedApi] postPath:@"/logout"
                   parameters:nil
                     callback:nil];

    [StatusView showTitle:@"Signing out" message:nil completion:^{
        [self clearUser];
    } duration:2];

    PNLOG(@"logout");
}

+(void) clearUser {
    NSLog(@"START CLEAR USER");

    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWillClearDataNotification object:nil userInfo:nil];
    
    // Erase user credentials
    PNUserPreferences* prefs = [PNUserPreferences shared];
    NSArray* wipeKeys = @[@"token", @"user_id", @"invite_token"];
    for (NSString* key in wipeKeys) {
        [prefs unsetPreference:key];
    }

    // Erase managed objects.
    NSManagedObjectContext* context = [App managedObjectContext];
    [context performBlockAndWait:^{

        // Save groups' deleted_at times before deleting
        NSArray* allGroups = [Group findAllUsingPredicate:nil sortedBy:nil];
        for (Group* g in allGroups) {
            if (g.deleted_at) {
                DeletedGroup* del = [DeletedGroup findOrCreateById:g.id inContext:context];
                del.deleted_at = g.deleted_at;
            }
        }

        [SkyMessage deleteAll];
        [Story deleteAll];

        [SkyAccount deleteAll];
        [Emoticon deleteAll];
        [IosPreference deleteAll];
        [User deleteAll];
        [UserGroupPreference deleteAll];
        [UserPreference deleteAll];

        [HashedEmail deleteAll];
        [HashedNumber deleteAll];

        [Group deleteAll];

        [SavedApiRequest deleteAll];

        [[AddressBookManager manager] clearCache];

        [context saveToRootWithCompletion:nil];
    }];

    [[PNUserPreferences shared] setPreference:@"tutorial_completed" boolValue:NO];

    // Clear cache data
    [[EGOCache globalCache] clearCache];
    [[SnapCache globalCache] clearCache];
    // Clear widget content
    [[ExtensionConduit shared] clearCache];

    // Done
    [StatusView dismiss];
    [[AppViewController sharedAppViewController] resetUI];

    [[NSNotificationCenter defaultCenter] postNotificationName:kDidClearDataNotification object:nil userInfo:nil];
    NSLog(@"done CLEAR USER");
}

+(NSString*)userId
{
    return [self getStringPreference:@"user_id"];
}

+(NSString*)username
{
    return [self getStringPreference:@"username"];
}

+(NSString*)myMentionName
{
    return [[NSString stringWithFormat:@"@%@", [[App username] stringByReplacingOccurrencesOfString:@" " withString:@""]] lowercaseString];
}

+(NSString*)token
{
    return [self getStringPreference:@"token"];
}

+(NSManagedObjectContext*)rootObjectContext
{
    return [[AppViewController sharedAppViewController] rootObjectContext];
}

+(NSManagedObjectContext*)managedObjectContext
{
    return [[AppViewController sharedAppViewController] mainObjectContext];
}

+(NSManagedObjectContext*)moc
{
    return [self managedObjectContext];
}

+(NSManagedObjectContext*)privateManagedObjectContext
{
    NSManagedObjectContext* context;
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [self managedObjectContext];
    return context;
}

+ (void)setPreference:(NSString *)key object:(id)value {
    PNUserPreferences* prefs = [PNUserPreferences shared];
    [prefs setPreference:key object:value];
    [prefs syncPreferences];
}

+ (CFPropertyListRef) getPreference:(NSString *)key {
    return [[PNUserPreferences shared] getCFPreference:key];
}

+ (NSString*) getStringPreference:(NSString *)key {
    id pref = [self getPreference:key];
    if ([pref isKindOfClass:[NSString class]])
        return (NSString*)pref;
    else
        return nil;
}

+ (AFNetworkReachabilityStatus) reachabilityStatus {
    return [[AppViewController sharedAppViewController] reachabilityStatus];
}

+ (NSString*)storedPasswordForUsername:(NSString*)username {
    if (username.length == 0) return nil;
    NSString* key = [NSString stringWithFormat:@"peanut_password_%@", username.lowercaseString];
    return [[PNUserPreferences shared] stringPreference:key];
}

+ (void)storePassword:(NSString*)password forUsername:(NSString*)username {
    if (username.length == 0) return;
    NSString* key = [NSString stringWithFormat:@"peanut_password_%@", username.lowercaseString];
    if (password.length == 0)
        [[PNUserPreferences shared] setPreference:key object:nil];
    else
        [[PNUserPreferences shared] setPreference:key stringValue:password];
}

+ (BOOL)isCrappyDevice {
    NSString* model = [PNSupport deviceName];
    if ([model isMatchedByRegex:@"iPod[345]"])
        return YES;
    else if ([model isMatchedByRegex:@"iPhone3"])
        return YES;
    else
        return NO;
}

+ (int)simulatanenousVideoLimit {
    int val = 0;
    val = [[Configuration settingFor:@"video_limit"] intValue];
    val = val ?: kSimultaneousVideoLimit;
    return [self isCrappyDevice] ? val : 2*val;
}

@end
