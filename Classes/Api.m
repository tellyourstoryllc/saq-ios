//
//  Api.m
//  chat
//
//  Created by Cragin Godley on 10/8/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "Api.h"
#import "App.h"
#import "AppViewController.h"

#import "JSONProcessor.h"
#import "FayeClient.h"
#import "Group.h"
#import "User.h"
#import "SkyMessage.h"

#import "PNUserPreferences.h"
#import "PNBackgroundTaskElf.h"
#import "PNRequestSigner.h"

@interface Api () <FayeClientDelegate>
@property (nonatomic) NSTimer* retryTimer;
@property (nonatomic) NSMutableDictionary *placeholderIdByFayeId;
@property (nonatomic, strong) dispatch_queue_t fayeQueue;
@property (nonatomic, strong) JSONProcessor* jsonProcessor;

@property (nonatomic, strong) NSMutableArray* fayeIncomingMessages;

@end

@interface ApiRequestSerializer : PNHTTPRequestSerializer
@end

@implementation Api
@synthesize fayeEnabled = _fayeEnabled;

+ (NSString*)serverUrlString {
    if ([[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference])
        return kDevServerAddress;
    return kProdServerAddress;
}

+ (NSString*)fastServerUrlString {
    if ([[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference])
        return kDevServerAddress;
    return kProdFastServerAddress;
}

+ (NSString*)slowServerUrlString {
    if ([[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference])
        return kDevServerAddress;
    return kProdSlowServerAddress;
}

+ (NSString*)socketUrlString {
    return [[PNUserPreferences shared] boolPreference:kDevApiServerSelectedPreference] ? kDevSocketAddress : kProdSocketAddress;
}

+ (Api *)sharedApi {
    return [self sharedApiForcingNewClient:NO];
}

+ (Api *)sharedApiForcingNewClient:(BOOL)force {
    static Api *api = nil;
    static dispatch_once_t onceToken;

    if (force) {
        PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self serverUrlString]]];
        client.requestSerializer = [[ApiRequestSerializer alloc] init];
        api = [[self alloc] initWithClient:client];
    }
    else {
        dispatch_once(&onceToken, ^{
            PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self serverUrlString]]];
            client.requestSerializer = [[ApiRequestSerializer alloc] init];
            api = [[self alloc] initWithClient:client];
        });
    }

    return api;
}

// Copy n' paste!

+ (Api *)fastApi {
    return [self fastApiForcingNewClient:NO];
}

+ (Api *)fastApiForcingNewClient:(BOOL)force {
    static Api *api = nil;
    static dispatch_once_t onceToken;

    if (force) {
        PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self fastServerUrlString]]];
        client.requestSerializer = [[ApiRequestSerializer alloc] init];
        api = [[self alloc] initWithClient:client];
    }
    else {
        dispatch_once(&onceToken, ^{
            PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self fastServerUrlString]]];
            client.requestSerializer = [[ApiRequestSerializer alloc] init];
            api = [[self alloc] initWithClient:client];
        });
    }

    return api;
}

+ (Api *)slowApi {
    return [self slowApiForcingNewClient:NO];
}

+ (Api *)slowApiForcingNewClient:(BOOL)force {
    static Api *api = nil;
    static dispatch_once_t onceToken;

    if (force) {
        PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self slowServerUrlString]]];
        client.requestSerializer = [[ApiRequestSerializer alloc] init];
        client.operationQueue.maxConcurrentOperationCount = 1;
        api = [[self alloc] initWithClient:client];
    }
    else {
        dispatch_once(&onceToken, ^{
            PNHTTPClient* client = [PNHTTPClient clientWithBaseURL:[NSURL URLWithString:[self slowServerUrlString]]];
            client.requestSerializer = [[ApiRequestSerializer alloc] init];
            client.operationQueue.maxConcurrentOperationCount = 1;
            api = [[self alloc] initWithClient:client];
        });
    }

    return api;
}

-(id)init {
    self = [super init];
    if(self) {
        self.fayeConnected = NO;
        self.placeholderIdByFayeId = [NSMutableDictionary dictionary];
        self.fayeQueue = dispatch_queue_create("com.perceptualnet.api.faye", DISPATCH_QUEUE_SERIAL);
        self.fayeIncomingMessages = [NSMutableArray new];
        self.jsonProcessor = [JSONProcessor singleton];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin) name:kLoginStateNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.fayeClient.webSocket.delegate = nil; // <-- FayeClient should be doing this?
    [self.fayeClient removeObserver:self forKeyPath:@"connectionInitiated"];
    [self.fayeClient removeObserver:self forKeyPath:@"webSocketConnected"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(self.fayeClient == object)
        if(!self.fayeClient.connectionInitiated && !self.fayeClient.webSocketConnected)
            self.fayeConnected = NO;
}

-(void) onLogin {
    on_low(^{
        self.fayeEnabled = [App isLoggedIn];
    });
}

- (void)process:(id)jsonObject withResponse:(NSHTTPURLResponse*)resp completion:(void (^)(NSMutableSet* entities, NSError* error))completion {
    [self parseResponse:jsonObject urlResponse:resp callback:^(NSSet *parsedEntities, id responseObject, NSError *parseError) {
        NSMutableSet* entities = [NSMutableSet setWithCapacity:10];
        [entities addObjectsFromArray:parsedEntities.allObjects];
        if (completion) completion(entities, parseError);
    }];
}

- (void) postPath:(NSString *)path parameters:(NSDictionary*)dict callback:(ApiRequestCallback)callback
{
    [self postPath:path withParameters:dict andCallback:^(NSData *data, NSHTTPURLResponse *response, id responseObject, NSSet *entities, NSError *error) {
        if (!error) {
            if (callback) callback(entities, responseObject, error);
        }
        else {
            NSLog(@"API returned error on %@: %@", path, error);
            [self onError:error callback:callback];
            if (response.statusCode == 401 && [path isMatchedByRegex:@"users|groups|contacts"]) {
                PNUserPreferences* prefs = [PNUserPreferences shared];
                [prefs unsetPreference:@"token"];
                [prefs unsetPreference:@"user_id"];
                [prefs unsetPreference:@"username"];
                [[AppViewController sharedAppViewController] resetUI];
            }
        }
    }];
}

- (void) parseResponse:(id)responseObject urlResponse:(NSHTTPURLResponse*)response callback:(ApiRequestCallback)callback
{
    [self.jsonProcessor.context performBlock:^{

        NSDate* start = [NSDate date];
        NSString *path = response ? response.URL.path : @"<socket>";

        NSError* error;
        NSMutableSet* entities = [NSMutableSet setWithCapacity:10];

        [self.jsonProcessor process:responseObject yieldingEntities:entities error:&error];
        if (error) NSLog(@"JSON process error: %@",error);

        [self.jsonProcessor.context saveToRootWithCompletion:^(BOOL success, NSError *err) {
            if (err) NSLog(@"JSON save context error: %@",error);

            NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:start];
            NSLog(@"parsed response to %@ in %0.1f ms", path, delta*1000);
            if (callback)
                callback(entities, responseObject, error ?: err);
        }];
        
    }];
}

- (void (^)(NSSet *entities, id responseObject, NSError *error)) authCallbackWithCompletion:(void (^)(BOOL authorized, NSError *error))completion {

    return ^(NSSet *entities, id responseObject, NSError *error) {

        __block User *user;

        // Find the user object.
        if(!error && entities) {
            [entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if([obj isKindOfClass:[User class]]) {
                    user = (User*)obj;
                    *stop=YES;
                }
            }];
        }

        if(user && [user token]) {
            NSLog(@"AUTH user: %@", user);
            [App setPreference:@"user_id" object:user.id];
            [App setPreference:@"username" object:user.username];
            [App setPreference:@"token" object:user.token];
            if (completion) completion(YES, nil);

        } else {
            if (completion) completion(NO, error);
        }
    };
}


- (void) onError:(NSError*)error callback:(ApiRequestCallback)callback
{
    if(error==nil)
        error = [NSError errorWithDomain:@"api" code:0 userInfo:@{@"message" : @"AFNetworking error"}];
    if(callback)
        callback(nil, nil, error);
}

#pragma mark Socket Client
-(BOOL) fayeEnabled {
    return _fayeEnabled;
}

-(void)setFayeEnabled:(BOOL)fayeEnabled {
    if(fayeEnabled == _fayeEnabled)
        return;
    
    _fayeEnabled = fayeEnabled;
    if(fayeEnabled) {
        on_default(^{
            [self.fayeClient connectToServer];
        });

    } else if (self.fayeConnected){
        [self clearRetryTimer];
        [self.fayeClient disconnectFromServer];
        
    }
}

-(FayeClient *)fayeClient {
    if(!_fayeClient) {
        _fayeClient = [[FayeClient alloc] initWithURLString:[Api socketUrlString] channel:nil];
        _fayeClient.delegate = self;
        [_fayeClient addObserver:self forKeyPath:@"connectionInitiated" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        [_fayeClient addObserver:self forKeyPath:@"webSocketConnected" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
    return _fayeClient;
}

-(void)sendMessage:(NSDictionary *)dict onChannel:(NSString *)channel {
    [self sendMessage:dict onChannel:channel withExt:nil];
}

-(void)sendMessage:(NSDictionary *)dict onChannel:(NSString *)channel withExt:(NSDictionary*)ext {
    dispatch_async(self.fayeQueue, ^{
        NSMutableDictionary* annotatedDict = [dict mutableCopy];
        [annotatedDict setObject:kCustomURLScheme forKey:@"app"];
        NSLog(@"Faye send on %@: %@", channel, annotatedDict);
        [self.fayeClient sendMessage:annotatedDict onChannel:channel withExt:ext];
    });
}

- (void)sendBackgroundMessage:(NSDictionary*)dict onChannel:(NSString*)channel withExt:(NSDictionary*)ext {
    [PNBackgroundTaskElf doIt:^(PNBackgroundTaskElf *elf) {
        [self sendMessage:dict onChannel:channel withExt:ext];
        [elf doneIt];
    }];
}

#pragma mark FayeClientDelegate
- (void)messageReceived:(NSDictionary *)dict channel:(NSString *)channel{
    NSLog(@"Faye message received (%@)",channel);
    [self.fayeIncomingMessages addObject:dict];

    // Shitty hack: batch up faye messages

    static float delayInSeconds;
    static NSDate* lastFayeMessageReceived;
    NSDate* now = [NSDate date];

    if (lastFayeMessageReceived && [now timeIntervalSinceDate:lastFayeMessageReceived] < 2.0)
        delayInSeconds += 1.5f;
    else if (lastFayeMessageReceived && [now timeIntervalSinceDate:lastFayeMessageReceived] > 10.0)
        delayInSeconds = 0.0f;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), self.parserQueue, ^{
        if (self.fayeIncomingMessages.count)
            [self parseFayeMessages];
    });

    lastFayeMessageReceived = [NSDate date];
}

- (void)parseFayeMessages {
    NSArray* messages = self.fayeIncomingMessages;
    self.fayeIncomingMessages = [NSMutableArray new];
    NSLog(@"parsing faye %d messages", messages.count);
    [self parseResponse:messages urlResponse:nil callback:^(NSSet *entities, id responseObject, NSError *error) {
    }];
}

- (void)connectedToServer {
    [self.fayeClient.webSocket setDelegateDispatchQueue:self.fayeQueue];
    self.fayeConnected = YES;
    [self clearRetryTimer];

    // Subscribe to personal channel
    dispatch_async(self.fayeQueue, ^{
        NSString *myChannel = [NSString stringWithFormat:@"/users/%@",[App userId]];
        [self.fayeClient subscribeToChannel:myChannel];
    });

    // Subscribe to my groups
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY members.id == %@", [App userId]];
    NSArray *groups = [Group findAllUsingPredicate:predicate inContext:[App moc]];
    for (Group *group in groups)
        if(group.isGroupValue) {
            __block NSString* channel = group.channel;
            dispatch_async(self.fayeQueue, ^{
                [self.fayeClient subscribeToChannel:channel];
            });
        }
    // Update client status
    [self sendMessage:@{
                        @"status" : @"active",
                        @"client_type" : @"phone"
                        }
            onChannel:@"/clients/update"];
}

-(void)setFayeConnected:(BOOL)fayeConnected {
    _fayeConnected = fayeConnected;
    [self.placeholderIdByFayeId removeAllObjects];
    
    if(self.fayeEnabled) {
        if(_fayeConnected)
            [self clearRetryTimer];
        else
            [self scheduleSocketRetry];
    }
}

- (void)disconnectedFromServer{
    self.fayeClient.webSocketConnected = NO;
    self.fayeConnected = NO;
}
- (void)connectionFailed{
    [self disconnectedFromServer];
}

-(void) scheduleSocketRetry {
    if(!self.fayeEnabled)
        return;
    [self clearRetryTimer];
    self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(retrySocket) userInfo:nil repeats:YES];
}

-(void) retrySocket {
    if ([[AppViewController sharedAppViewController] reachabilityStatus] == AFNetworkReachabilityStatusNotReachable) return;
    if(self.fayeEnabled && !self.fayeClient.connectionInitiated && !self.fayeClient.webSocketConnected) {
        on_default(^{
            [self.fayeClient connectToServer];
        });
    }
}

- (void)didSubscribeToChannel:(NSString *)channel{
}

- (void)didUnsubscribeFromChannel:(NSString *)channel{
}

- (void)subscriptionFailedWithError:(NSString *)error{

    if ([error isMatchedByRegex:@"token"]) {
        PNLOG(@"logout.faye_error");
        // [App clearUser];
    }

    NSLog(@"Faye subscription failed: %@", error);
}
- (void)fayeClientError:(NSError *)error{
    NSLog(@"Faye client error: %@", error);
}

-(void)clearRetryTimer {
    if(self.retryTimer)
        [self.retryTimer invalidate];
    self.retryTimer = nil;
}

#pragma mark Faye Extensions
- (void)fayeClientWillReceiveMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback{
//    NSLog(@"Faye received message: %@",messageDict);

    // Message placeholder tracking
    NSNumber *successNumber = messageDict[@"successful"];
    NSString *fayeId = successNumber ? messageDict[@"id"] : nil;
    NSString *placeholder_id = fayeId ? self.placeholderIdByFayeId[fayeId] : nil;

    if(placeholder_id) {

        BOOL transmission_failed = [[NSNumber numberWithInt:0] isEqualToNumber:messageDict[@"successful"]];

        if (transmission_failed) {
            NSManagedObjectContext* context = [App privateManagedObjectContext];
            SkyMessage *placeholder = [[SkyMessage findByIds:@[placeholder_id] inContext:context] lastObject];
            placeholder.transmission_failedValue = YES;
            [context save:nil];

        } else {
            [self.placeholderIdByFayeId removeObjectForKey:placeholder_id];
            // DON'T delete the placeholder here. Instead, wait for replacement Message to be parsed. UI much smoother this way.
        }
        
    }
    callback(messageDict);
}
- (void)fayeClientWillSendMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback{
    NSMutableDictionary *ext = [[messageDict objectForKey:@"ext"] mutableCopy];
    if(!ext)
        ext = [NSMutableDictionary dictionary];
    [ext setValue:[App token] forKey:@"token"];

    NSMutableDictionary *result = [messageDict mutableCopy];
    [result setValue:ext forKeyPath:@"ext"];
    
    // Message placeholder tracking
//    NSDictionary* metadata = [messageDict valueForKeyPath:@"data.client_metadata"];
//    NSString *placeholder_id = [metadata valueForKey:@"placeholder_id"];
    id metadataString = [messageDict valueForKey:@"data.client_metadata"];
    if (metadataString && metadataString != [NSNull null]) {
        NSDictionary* metadata = [NSJSONSerialization JSONObjectWithData:[metadataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:nil];
        NSString* placeholder_id = metadata[@"placeholder"];
        if (placeholder_id) [self.placeholderIdByFayeId setObject:placeholder_id forKey:messageDict[@"id"]];
    }

//    NSLog(@"Faye sending message: %@",result);
    callback(result);
}

@end

@implementation ApiRequestSerializer

+ (NSDictionary*) signedParams:(NSDictionary*)parameters forUrl:(NSString*)url {
    
    // Remove scheme and host
    NSString *path = [url stringByReplacingOccurrencesOfRegex:@"^[^:]+://[^/]+" withString:@""];

    NSMutableDictionary* p = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [p setValue:[PNSupport version] forKey:@"client_version"];
    [p setValue:[PNSupport clientID] forKey:@"device_id"];
    [p setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    [p setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"lang"];
    [p setValue:@"ios" forKey:@"client"];
    [p setValue:kCustomURLScheme forKey:@"app"];

    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi])
        [p setValue:@"wifi" forKey:@"conn"];

    NSString *token = [App getStringPreference:@"token"];
    if (token) [p setValue:token forKey:@"token"];

    return [PNRequestSigner signedParametersForPath:path parameters:p];
}

@end