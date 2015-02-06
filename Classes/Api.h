//
//  Api.h
//  chat
//
//  Created by Cragin Godley on 10/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "FayeClient.h"
#import "PNAPIAdapter.h"

#define kLoginStateNotification @"login_state"
#define kDevApiServerSelectedPreference @"kDevApiServerSelectedPreference"

typedef void(^ApiRequestCallback)(NSSet *entities, id responseObject, NSError *error);

@interface Api : PNAPIAdapter
@property (nonatomic) FayeClient *fayeClient;
@property (nonatomic) BOOL fayeEnabled;
@property (nonatomic) BOOL fayeConnected;

+ (Api *)sharedApi;
+ (Api *)sharedApiForcingNewClient:(BOOL)force; // <-- needed for when we want to change the endpoint dynamically.

+ (Api *)fastApi;
+ (Api *)fastApiForcingNewClient:(BOOL)force;

+ (Api *)slowApi;
+ (Api *)slowApiForcingNewClient:(BOOL)force;

// A higher level post method that also logs user out of client if 401 response received. (e.g., user changed password)
- (void) postPath:(NSString *)path
       parameters:(NSDictionary*)parameters
         callback:(ApiRequestCallback)callback;

- (void (^)(NSSet *entities, id responseObject, NSError *error)) authCallbackWithCompletion:(void (^)(BOOL authorized, NSError *error))completion;

- (void)sendMessage:(NSDictionary*)dict onChannel:(NSString*)channel;
- (void)sendMessage:(NSDictionary*)dict onChannel:(NSString*)channel withExt:(NSDictionary*)ext;
- (void)sendBackgroundMessage:(NSDictionary*)dict onChannel:(NSString*)channel withExt:(NSDictionary*)ext;

@end

