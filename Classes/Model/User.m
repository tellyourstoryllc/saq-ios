#import "User.h"
#import "Api.h"
#import "App.h"
#import "HashedEmail.h"
#import "HashedNumber.h"
#import "SDWebImageManager.h"
#import "Story.h"

@interface User ()

@end


@implementation User
@synthesize mentionName = _mentionName;

+ (id)findByUsername:(NSString*)name inContext:(NSManagedObjectContext*)moc {
    return [[self findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id != NULL AND username == %@", name] inContext:moc] lastObject];
}

+ (id)findOrCreateByUsername:(NSString*)name inContext:(NSManagedObjectContext*)moc {
    User* user = [self findByUsername:name inContext:moc];
    if (user) return user;

    user = [self findOrCreateById:name inContext:moc];
    user.username = name;
    return user;
}

+(NSDictionary*)statusOrdinalByStatus {
    static NSDictionary *map;
    if(!map)
        map = @{
                @"available": @0,
                @"away": @1,
                @"do_not_disturb": @2,
                @"idle": @3,
                @"unavailable": @4
                };
    return map;
}

+ (User*)me {
    return [self meInContext:[App moc]];
}

+ (User*)meInContext:(NSManagedObjectContext*)moc {
    NSString* userId = [App userId];
    return userId ? [[self findByIds:@[userId] inContext:moc] lastObject] : nil;
}

+ (void)fetchUserNamed:(NSString*)name completion:(void (^)(User* user))completion {
    if (!name) {
        if (completion) completion(nil);
        return;
    }

    User* user = [[self findAllUsingPredicate:[NSPredicate predicateWithFormat:@"username == %@", name] inContext:[App moc]] lastObject];
    if (user) {
        if (completion) completion(user);
    }
    else {
        [[Api sharedApi] postPath:@"/users"
                       parameters:@{@"usernames":name}
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             User* user = [[entities setOfClass:[User class]] anyObject];
                             if (completion) completion(user);
                         }];
    }
}

+ (void)fetchUserId:(NSString*)userId completion:(void (^)(User* user))completion {
    User* user = [[self findByIds:@[userId] inContext:[App moc]] lastObject];
    if (user) {
        if (completion) completion(user);
    }
    else {
        [[Api sharedApi] postPath:@"/users"
                       parameters:@{@"ids":userId}
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             User* user = [[entities setOfClass:[User class]] anyObject];
                             if (completion) completion(user);
                         }];
    }
}

+ (void)fetchUserIds:(NSArray*)idArray completion:(void (^)(NSArray* users))completion {
    NSArray* results = [self findByIds:idArray inContext:[App moc]];
    if (results.count != idArray.count) {
        [[Api sharedApi] postPath:@"/users"
                       parameters:@{@"ids":idArray}
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             NSArray* users = [[entities setOfClass:[User class]] allObjects];
                             if (completion) completion(users);
                         }];
    }
    else {
        if (completion) completion(results);
    }
}

+ (void)fetchFriendsWithCompletion:(void (^)(NSArray* userArray))completion {
    [[Api sharedApi] postPath:@"/friends"
                   parameters:nil
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSMutableArray* userIds = [[NSMutableArray alloc] initWithCapacity:4];

                         NSArray* incomingIds = responseObject[0][@"incoming_friend_ids"];
                         NSArray* outgoingIds = responseObject[0][@"outgoing_friend_ids"];
                         NSArray* mutualIds = responseObject[0][@"mutual_friend_ids"];

                         [userIds addObjectsFromArray:incomingIds];
                         [userIds addObjectsFromArray:outgoingIds];
                         [userIds addObjectsFromArray:mutualIds];

                         NSArray* dedupedIds = [[[NSSet alloc] initWithArray:userIds] allObjects];
                         [self fetchUserIds:dedupedIds
                                 completion:^(NSArray *users) {
                                     for (User* user in users) {
                                         if ([incomingIds containsObject:user.id])
                                             user.is_incoming_friendValue = YES;

                                         if ([outgoingIds containsObject:user.id])
                                             user.is_outgoing_friendValue = YES;
                                     }

                                     [[[users lastObject] managedObjectContext] saveToRootWithCompletion:^(BOOL success, NSError *err) {
                                         if (completion) completion(users);
                                     }];
                         }];

                     }];
}

- (void)delete {
    if (self.id)
        self.id = nil;
    else
        [self destroyAndSave:NO];
}

- (BOOL)isMe {
    return [self.id isEqualToString:[App userId]];
}

-(void)awakeFromRemoteWithJson:(id)json context:(NSManagedObjectContext *)moc {
    [super awakeFromRemoteWithJson:json context:moc];

    NSNumber *ordinal = [[User statusOrdinalByStatus] valueForKey:self.status];
    if(!ordinal)
        ordinal = @3;
    self.status_ordinal = ordinal;
    self.idle_start_timeValue = [[NSDate date] timeIntervalSince1970] - self.idle_durationValue;

    id rawname = json[@"username"];
    self.raw_username = [rawname isKindOfClass:[NSString class]] ? rawname : nil;
    
    if ([self.username isMatchedByRegex:@"^_"]) self.username = nil;
    if ([self.name isMatchedByRegex:@"^_"]) self.name = nil;

    NSArray* hashedEmails = [json objectForKey:@"hashed_emails"];
    for (NSString* hash in hashedEmails) {
        HashedEmail* obj = [HashedEmail findOrCreateById:hash inContext:moc];
        obj.user = self;
        [self.hashed_emailsSet addObject:obj];
    }

    NSArray* hashedNumbers = [json objectForKey:@"hashed_phone_numbers"];
    for (NSString* hash in hashedNumbers) {
        HashedNumber* obj = [HashedNumber findOrCreateById:hash inContext:moc];
        obj.user = self;
        [self.hashed_numbersSet addObject:obj];
    }

    // Look for temp users and delete them:
    [self killDoppelganger];

//    User *staleUser = [[User findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@",self.username] inContext:moc] lastObject];
//    if(staleUser) {
//        [staleUser destroyAndSave:NO];
//    }

    [self associateWithStories];

//    NSArray* replacedUsers = [json objectForKey:@"replaced_user_ids"];
//    NSString* replacedBy = [json objectForKey:@"replaced_by_user_id"];
}

-(NSString*)displayName {
    NSString *name = self.address_book_name ?: self.username;
    if ([self isMe]) {
        return [name stringByAppendingString:@" (YOU)"];
    }
    else {
        return name;
    }
}

-(NSString*)alternateName {
    return self.address_book_name ? self.username : nil;
}

-(NSString *)mentionName {
    if(!_mentionName)
        _mentionName = [NSString stringWithFormat:@"@%@",[self.username stringByReplacingOccurrencesOfString:@" " withString:@""]];
    return _mentionName;
}

- (NSString *)stringForIdleInterval {

    NSTimeInterval intervalInSeconds = [NSDate date].timeIntervalSince1970 - self.idle_start_timeValue;
    double intervalInMinutes = round(intervalInSeconds/60.0);

    if (intervalInMinutes >= 0 && intervalInMinutes <= 1) return [NSString stringWithFormat:@"%.0f seconds", intervalInSeconds];
    else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) return [NSString stringWithFormat:@"%.0f minutes", intervalInMinutes];
    else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) return @"about 1 hour";
    else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) return [NSString stringWithFormat:@"%.0f hours", round(intervalInMinutes/60.0)];
    else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) return @"about 1 day";
    else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) return [NSString stringWithFormat:@"%.0f days", round(intervalInMinutes/1440.0)];
    else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) return @"1 month";
    else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) return [NSString stringWithFormat:@"%.0f months", round(intervalInMinutes/43200.0)];
    else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) return @"1 year";
    else
        return [NSString stringWithFormat:@"> %.0f years", round(intervalInMinutes/525600.0)];
}

- (Group*)oneToOneGroup {
    return [self oneToOneGroupInContext:[App moc]];
}

- (Group*)oneToOneGroupInContext:(NSManagedObjectContext*)moc {
    if (![App userId]) return nil;

    if (self.isTemporary) {
        NSLog(@"ERROR: Attempt to get oneToOne for temporary user: %@", self);
        return nil;
    }

    __block Group* oneToOne;

    [moc performBlockAndWait:^{
        NSString *conversationId = [Group oneToOneIdForUser:self];
        oneToOne = [[Group findByIds:@[conversationId] inContext:moc] firstObject];
        if (!oneToOne) {
            Group* newOneToOne = [Group findOrCreateById:conversationId inContext:moc];
            newOneToOne.json = @{
                                 @"object_type" : @"one_to_one",
                                 @"id" : conversationId,
                                 @"member_ids" : @[[App userId], self.id]
                                 };
            [newOneToOne awakeFromRemoteWithContext:moc];

            NSError *error;
            BOOL savedOK = [moc save:&error];
            if(savedOK) oneToOne = newOneToOne;
        }
    }];

    return oneToOne;
}

- (BOOL)hasAvatar {
    return (self.avatar_url.length || self.avatar_video_url.length);
}

- (BOOL)isTemporary {
    return self.id == nil || ([self.id compare:self.username options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

- (void)fetchAvatarWithCompletion:(void (^)(UIImage* image))completion {
    if (![self hasAvatar]) {
        if (completion) completion(nil);
        return;
    }

    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.avatar_url]
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (completion) completion(image);
                                                  }];
}

- (void)killDoppelganger {
    if (!self.isTemporary)
        [User fetchAllUsingPredicate:[NSPredicate predicateWithFormat:@"id ==[c] %@",self.username] // [c] -> case insensitive match
                            sortedBy:nil limit:0 offset:0
                           inContext:self.managedObjectContext
                          completion:^(NSArray *results) {
                              for (User* user in results) {
                                  [user delete];
                              }
                          }];
}

- (NSArray*)associateWithStories {
    NSArray* stories = [Story findAllUsingPredicate:[NSPredicate predicateWithFormat:@"user = NULL AND user_id = %@ AND id != NULL AND deleted != YES", self.id]
                                            sortedBy:nil
                                               limit:0
                                             offset:0
                                          inContext:self.managedObjectContext];
    for (Story* story in stories) {
        story.user = self;
    }
    return stories;
}

- (void)updateLastStory {
    Story* lastStory = [[Story findAllUsingPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND id != NULL AND deleted != YES", self]
                                            sortedBy:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                               limit:1 offset:0 inContext:self.managedObjectContext] lastObject];
    [self updateIfLastStory:lastStory];
}

- (void)updateIfLastStory:(Story*)story {
    if (!self.last_story_at || !self.last_story || !self.last_story.id || [story.created_at timeIntervalSinceDate:self.last_story_at] > 0) {
        self.last_story = story;
        self.last_story_at = story.created_at;
    }

    if (story.viewedValue) {
        if (!self.last_seen_story_at) {
            self.last_seen_story_at = story.created_at;
        }
        else if ([self.last_seen_story_at timeIntervalSinceDate:story.created_at] < 0) {
            self.last_seen_story_at = story.created_at;
        }
    }
}

- (BOOL)hasUnreadStory {
    return self.last_story && (!self.last_seen_story_at || ([self.last_seen_story_at timeIntervalSinceDate:self.last_story_at] < 0));
}

- (UIColor*)color {
    return COLOR(blueColor);
}

@end
