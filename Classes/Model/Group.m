#import "Group.h"
#import "User.h"
#import "App.h"
#import "Api.h"
#import "SavedApiRequest.h"
#import "UploadProgressAlertView.h"
#import "PNVideoComposer.h"
#import "EGOCache.h"
#import "SkyMessage.h"
#import "PNBackgroundTaskElf.h"
#import "PNVideoCompressor.h"

@interface Group ()
@property (nonatomic, assign) BOOL isLoadingMessages;
@end

@implementation Group
@synthesize join_code = _join_code;
@synthesize isLoadingMessages = _isLoadingMessages;

+ (NSArray*)activeGroups {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"ANY members.id == %@ AND last_message_at != NULL AND ((deleted_at == NULL) OR (deleted_at < last_message_at))", [App userId]];
    NSArray* sort = @[
                      [NSSortDescriptor sortDescriptorWithKey:@"last_message_at" ascending:NO],
                      [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                      ];
    return [self findAllUsingPredicate:pred sortedBy:sort limit:10];
}

-(void)awakeFromRemoteWithJson:(id)json context:(NSManagedObjectContext *)moc
{
    BOOL loadUsers = NO;
    
    if(!self.last_seen_at) {
        self.last_seen_at = [NSDate date];
    }
    
    if ([self.name isMatchedByRegex:@"^_"]) self.name = nil;
    
    id admin_ids = [json objectForKey:@"admin_ids"];
    if([admin_ids isKindOfClass:[NSArray class]]) {
        NSArray *admins = [User findByIds:admin_ids inContext:moc];
        for (User* user in admins) {
            user.is_communicatingValue = YES;
        }
        [self setAdmins:[NSSet setWithArray:admins]];
        if ([(NSArray*)admin_ids count] > admins.count) loadUsers = YES;
    }
    
    id member_ids = [json objectForKey:@"member_ids"];
    if([member_ids isKindOfClass:[NSArray class]]) {
        NSArray *members = [User findByIds:member_ids inContext:moc];
        for (User* user in members) {
            user.is_communicatingValue = YES;
        }
        [self setMembers:[NSSet setWithArray:members]];
        if ([(NSArray*)member_ids count] > members.count) loadUsers = YES;
    }
    
    self.isVirtualOneToOneValue = ![@"one_to_one" isEqualToString:[json objectForKey:@"object_type"]] && self.members.count < 3;
    self.isGroupValue = ![@"one_to_one" isEqualToString:[json objectForKey:@"object_type"]];
    self.isOneToOneValue = !self.isGroupValue || self.isVirtualOneToOneValue;
    
    if (loadUsers) {
        admin_ids = admin_ids ?: @[];
        NSArray* storedAdminIds = [[self.admins allObjects] mapUsingBlock:^id(id obj) {
            return [obj id];
        }];
        NSMutableArray* missingAdminIds = [admin_ids mutableCopy];
        [missingAdminIds removeObjectsInArray:storedAdminIds];
        
        member_ids = member_ids ?: @[];
        NSArray* storedMemberIds = [[self.members allObjects] mapUsingBlock:^id(id obj) {
            return [obj id];
        }];
        NSMutableArray* missingMemberIds = [member_ids mutableCopy];
        [missingMemberIds removeObjectsInArray:storedMemberIds];
        
        NSArray* missingIds = [missingAdminIds arrayByAddingObjectsFromArray:missingMemberIds];
        
        if (missingIds.count) {
            NSString* selfId = self.id;
            [[Api sharedApi] postPath:@"/users"
                           parameters:@{@"ids":[missingIds componentsJoinedByString:@","]}
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 NSManagedObjectContext* context = [App privateManagedObjectContext];
                                 Group* selfish = [[Group findByIds:@[selfId] inContext:context] firstObject];
                                 NSArray *admins = [User findByIds:admin_ids inContext:context];
                                 [selfish setAdmins:[NSSet setWithArray:admins]];
                                 NSArray *members = [User findByIds:member_ids inContext:context];
                                 [selfish setMembers:[NSSet setWithArray:members]];
                                 selfish.updated_at = [NSDate date];
                                 [self updateIsHidden];
                                 [context save:nil];
                             }];
        }
    }
    
    if(self.isOneToOneValue) {
        self.other_user = [self.otherMembers anyObject];
        if (self.other_user) {
            self.other_user.has_one_to_oneValue = YES;
            self.other_user.is_communicatingValue = self.max_rankValue && (self.max_rankValue > self.last_deleted_rankValue);
        }
        else {
            // Special case...
            self.other_user = [User meInContext:moc];
        }
        self.name = self.other_user.displayName;
    }
    
    if (!self.deleted_at) {
        DeletedGroup* del = [[DeletedGroup findByIds:@[self.id] inContext:moc] lastObject];
        self.deleted_at = del.deleted_at;
    }
    
    [self updateIsHidden];
}

//- (void)delete {
//    if (self.id) {
//        self.id = nil;
//        self.admins = nil;
//        self.members = nil;
//        self.messages = nil;
//    }
//    else
//        [self destroyAndSave:NO];
//}

-(NSString *)join_code {
    if(!self.join_url)
        return nil;
    
    if(!_join_code) {
        NSTextCheckingResult *result = [[Group joinRegex] firstMatchInString:self.join_url options:0 range:NSMakeRange(0, self.join_url.length)];
        _join_code = [self.join_url substringWithRange:[result rangeAtIndex:0]];
    }
    
    return _join_code;
}

-(NSString *)channel
{
    if (!self.id) return nil;
    if (self.isGroupValue)
        return [NSString stringWithFormat:@"/groups/%@/messages", self.id];
    else
        return [NSString stringWithFormat:@"/users/%@", self.other_user.id];
}

-(NSString *)path
{
    if (!self.id) return nil;
    if (self.isGroupValue)
        return [NSString stringWithFormat:@"/groups/%@", self.id];
    else
        return [NSString stringWithFormat:@"/one_to_ones/%@", self.id];
}

-(BOOL)hasUnreadMessages {

//    NSLog(@"%@ %@ %@ %@ %@ %@", self.other_user.name, self.last_seen_rank, self.last_message_at, self.last_deleted_rank, self.max_rank, self.last_seen_at);

    if (self.last_message.user.isMe)
        return NO;

    else if(!self.last_message_at)
        return NO;
    
    else if(!self.last_seen_at)
        return YES;
    
    else if (!self.last_seen_rank && self.last_message_at)
        return YES;
    
    else if (self.last_deleted_rankValue >= self.max_rankValue)
        return NO;
    
    else if (self.last_seen_rankValue < self.max_rankValue)
        return YES;
    
    return NO;
}

-(BOOL)isMissingMessages {
    if (!self.last_message_at)
        return NO;
    else if (!self.last_received_message_at)
        return YES;
    else
        return ([self.last_message_at compare:self.last_received_message_at] == NSOrderedDescending);
}

+(NSRegularExpression*)joinRegex {
    static NSRegularExpression *pattern = nil;
    if(!pattern)
        pattern = [NSRegularExpression regularExpressionWithPattern:@"[^/]+$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    return pattern;
}

+(NSRegularExpression*)mentionRegex {
    static NSRegularExpression *r = nil;
    if(!r)
        r = [NSRegularExpression regularExpressionWithPattern:@"(^|[^\\w])@(\\w+)" options:0 error:nil];
    //        r = [NSRegularExpression regularExpressionWithPattern:@"(^|[^\\w])(@\\w+)" options:0 error:nil];
    return r;
}

+(NSString*) oneToOneIdForUser: (User*) user {
    if (user == nil || user.isTemporary)
        return nil;
    
    return [Group oneToOneIdForUserId:user.id];
}

+(NSString*) oneToOneIdForUserId: (NSString*) userId {
    if(userId == nil)
        return nil;
    
    NSArray *userIds = @[userId, [App userId]];
    userIds = [userIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [NSString stringWithFormat:@"%@-%@", userIds.firstObject, userIds.lastObject];
}

- (BOOL)isAdmin {
    return [self.admins containsObject:[User me]];
}

- (BOOL)hasAdmin:(User*)user {
    if (!user) return NO;
    return [self.admins containsObject:user];
}

- (BOOL)isMember {
    return [self.members containsObject:[User me]];
}

- (BOOL)hasMember:(User*)user {
    if (!user) return NO;
    return [self.members containsObject:user];
}

-(void)setDeleted_at:(NSDate *)deleted_at {

    // Boilerplate NSManagedObject setter
    [self willChangeValueForKey:@"deleted_at"];
    [self setPrimitiveValue:deleted_at forKey:@"deleted_at"];
    [self didChangeValueForKey:@"deleted_at"];
    // -----------------------------------
    
    [self updateLastMessage];
}

- (void) updateLastMessage
{
    self.last_message = [self lastMessage];

    if (self.last_message && !self.last_message.isMeta)
        self.last_nonmeta_message = self.last_message;

    if (self.last_message && self.last_message.user.isMe && !self.last_message.isMeta)
        self.last_user_message = self.last_message;

    if (!self.last_user_message)
        self.last_user_message = [self lastUserMessage];
}

- (SkyMessage*)lastMessage {

    if (!self.id)
        return nil;

    if (self.deleted_at)
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND created_at > %@", self.id, self.deleted_at]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
    else
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@", self.id]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
}

- (SkyMessage*)lastNonMetaMessage {
    if (!self.id)
        return nil;

    if (self.last_nonmeta_message)
        return self.last_nonmeta_message;

    // Just in case..
    if (self.deleted_at)
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND created_at > %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id, self.deleted_at]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                            offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
    else
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
}

- (SkyMessage*)lastUserMessage {

    if (!self.id)
        return nil;

    if (self.deleted_at)
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND created_at > %@ AND user_id = %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id, self.deleted_at, [App userId]]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
    else
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND user_id = %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id, [App userId]]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
}

- (SkyMessage*)lastOtherUserMessage {
    if (!self.id)
        return nil;

    if (self.deleted_at)
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND created_at > %@ AND user_id != %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id, self.deleted_at, [App userId]]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
    else
        return [[SkyMessage findAllUsingPredicate:[NSPredicate predicateWithFormat:@"group.id == %@ AND user_id != %@ AND (attachment_type != 'meta' OR attachment_type = NULL)", self.id, [App userId]]
                                         sortedBy:@[
                                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO],
                                                    [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]
                                                    ]
                                            limit:1
                                           offset:0
                                        inContext:self.managedObjectContext]
                firstObject];
}

// Hide this group if no other users, or all other users are blocked
- (void)updateIsHidden {
    // Special case. 1:1 with oneself
    if (!self.isGroupValue && self.otherMembers.count == 0)
        self.isHiddenValue = NO;
    else {
        BOOL shouldHide = YES;
        for (User* user in self.otherMembers) {
            if (!user.is_blockedValue) {
                shouldHide = NO;
                break;
            }
        }
        self.isHiddenValue = shouldHide;
    }
}

- (void)loadMessagesWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion
{
    if (_isLoadingMessages) {
        if (completion) completion(nil,nil,nil);
    }
    else {
        _isLoadingMessages = YES;
        [[Api sharedApi] postPath:self.path
                       parameters:nil
                         callback:^(NSSet *entities, id responseObject, NSError *error) {
                             [self.managedObjectContext performBlock:^{
                                 self.last_received_message_at = self.last_message_at;
                                 if (completion) completion(entities, responseObject, error);
                                 _isLoadingMessages = NO;
                             }];
                         }];
    }
}

- (void)markReadWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion {
    [self.managedObjectContext performBlock:^{
        SkyMessage* m = self.last_message;
        NSInteger rank = m.rankValue;
        
        if (rank > self.last_seen_rankValue || !self.last_seen_rank) {
            self.last_seen_rankValue = rank;
            NSString* groupType = self.isGroupValue ? @"groups" : @"one_to_ones";
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/%@/%@/update", groupType, self.id]
                           parameters:@{@"last_seen_rank":@(rank)}
                             callback:completion];
        }
        else {
            if (completion) completion([NSSet setWithObject:self], nil, nil);
        }

        self.updated_at = [NSDate date];
        [self save];
    }];
}

- (void)markDeletedWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion {
    [self.managedObjectContext performBlock:^{
        SkyMessage* m = self.last_message;
        NSInteger rank = m.rankValue;
        
        if (rank > self.last_deleted_rankValue || !self.last_deleted_rank) {
            self.last_seen_rankValue = rank;
            NSString* groupType = self.isGroupValue ? @"groups" : @"one_to_ones";
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/%@/%@/update", groupType, self.id]
                           parameters:@{@"last_deleted_rank":@(rank)}
                             callback:completion];
        }
        else {
            if (completion) completion([NSSet setWithObject:self], nil, nil);
        }
    }];
}

+ (void)publishVideo:(NSURL*)videoUrl
             orImage:(UIImage*)image
         withOverlay:(UIImage*)overlayImage
            toGroups:(NSArray*)groups
              params:(NSDictionary*)params
          completion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion {

    if (videoUrl ) {

        __block EGOCache* cache = [EGOCache globalCache];

        __block NSString* cacheKey = videoUrl.lastPathComponent;
        [cache moveFileUrl:videoUrl asKey:cacheKey];
        __block NSURL* cacheUrl = [cache urlForKey:cacheKey];
        [cache waitForDisk];

        [PNVideoCompressor compressVideoUrl:cacheUrl
                                     preset:AVAssetExportPresetMediumQuality
                                   filetype:AVFileTypeMPEG4
                                 exportWith:^(AVAssetExportSession *exportSession) {
                                     // Skip the first 0.2s to avoid possible black frame.
                                     exportSession.timeRange = CMTimeRangeMake(CMTimeMake(2, 10), kCMTimePositiveInfinity);
                                 }
                             withCompletion:^(NSURL *compressedVideoUrl, NSError *error) {
                                 [cache removeCacheForKey:cacheKey];
                                 [self uploadVideo:compressedVideoUrl
                                        andOverlay:overlayImage
                                          toGroups:groups
                                        withParams:params
                                     andCompletion:^(BOOL success, BOOL cancelled, NSSet *entities) {
                                         [[NSFileManager defaultManager] removeItemAtURL:compressedVideoUrl error:nil];
                                         if (completion) completion(success, cancelled, entities);
                                     }];
                             }];
    }
    else {
        [self uploadPhoto:image andOverlay:overlayImage toGroups:groups withParams:params andCompletion:completion];
    }
}

+ (void)uploadVideo:(NSURL*)videoUrl
         andOverlay:(UIImage*)overlayImage
           toGroups:(NSArray*)groups
         withParams:(NSDictionary*)extraParams
      andCompletion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion {

    if (!groups.count) {
        if (completion) completion(YES,NO, nil);
        return;
    }

    NSString* placeholderId = [NSString stringWithFormat:@"%@%@", [App userId], [NSString randomStringOfLength:32]];
    NSDictionary* originalMetadata = extraParams[@"metadata"] ?: @{};
    NSMutableDictionary* metadata = [originalMetadata mutableCopy];
    [metadata setObject:placeholderId forKey:@"placeholder"];
    __block NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                             encoding:NSUTF8StringEncoding];

    PNLOG(@"group.send_video");

    [PNBackgroundTaskElf
     doIt:^(PNBackgroundTaskElf *elf) {
         NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:[videoUrl path]];
         if(!mediaData) {
             NSLog(@"Failed to load video at path %@", videoUrl.path);
             if(completion)
                 completion(NO, NO, nil);
             return;
         }

         [PNVideoComposer fetchScreenshotForVideoUrl:videoUrl atTime:0.1 completion:^(UIImage *screenshot, Float64 actualTime) {

             NSMutableArray* groupIds = [NSMutableArray arrayWithCapacity:groups.count];
             NSMutableArray* oneToOneIds = [NSMutableArray arrayWithCapacity:groups.count];
             NSMutableArray* recipients = [NSMutableArray arrayWithCapacity:groups.count];

             for (Group* group in groups) {
                 if ([group isGroupValue])
                     [groupIds addObject:group.id];
                 else {
                     if(!group.other_user)
                         continue;

                     [oneToOneIds addObject:group.id];
                     [recipients addObject:group.other_user];
                 }
             };

             NSMutableDictionary *params = [@{ @"group_ids" : [groupIds componentsJoinedByString:@","],
                                               @"one_to_one_ids" : [oneToOneIds componentsJoinedByString:@","],
                                               //                                          @"expires_in" : @(86400*30)
                                               @"client_metadata" : metadataString
                                               } mutableCopy];
             if (extraParams) [params addEntriesFromDictionary:extraParams];

             NSData* overlayData = overlayImage ? UIImagePNGRepresentation(overlayImage) : nil;

             SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/messages/create"
                                                                  parameters:params
                                                                     dataURL:videoUrl
                                                                   dataParam:@"attachment_file"
                                                                dataMimeType:@"video/mp4"
                                                                       data2:overlayData
                                                                  data2Param:@"attachment_overlay_file"
                                                               data2MimeType:@"image/png"
                                        ];

             // Create placeholder
             if (upload) {

                 SnapCache* cache = [SnapCache shared];
                 NSString* overlayKey = [NSString stringWithFormat:@"%@_overlay.png", placeholderId];
                 if (overlayData) [cache setData:overlayData forKey:overlayKey];

                 NSString* ssKey = [NSString stringWithFormat:@"%@_screenshot.png", placeholderId];
                 NSData* previewData = screenshot ? UIImagePNGRepresentation(screenshot) : nil;
                 [cache setData:previewData forKey:ssKey];

                 for (Group* group in groups) {
                     SkyMessage *message = [SkyMessage findOrCreateById:placeholderId inContext:group.managedObjectContext];
                     message.is_placeholderValue = YES;
                     message.user_id = [App userId];
                     message.user = [User me];
                     message.group = group;
                     message.created_at = [NSDate date];
                     message.rankValue = group.max_rankValue+1;
                     message.attachment_url = [[NSURL fileURLWithPath:upload.data_filepath] absoluteString];
                     message.attachment_overlay_url = overlayData ? [[cache urlForKey:overlayKey] absoluteString] : nil;
                     message.attachment_type = @"video";
                     message.attachment_content_type = @"video/mp4";
                     message.attachment_preview_url = previewData ? [[cache urlForKey:ssKey] absoluteString] : nil;
                     message.attachment_preview_width = @(screenshot.size.width);
                     message.attachment_preview_height = @(screenshot.size.height);

                     [message.saved_requestsSet addObject:upload];
                     upload.placeholder = message;
                 }

                 [[[groups firstObject] managedObjectContext] saveToRootWithCompletion:nil];
             }

             AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {

                 SkyMessage* message = [[entities setOfClass:[SkyMessage class]] anyObject];
                 [message fetchVideoWithCompletion:nil];

                 [message.managedObjectContext performBlock:^{
                     message.group.updated_at = [NSDate date];
                     [message.group save];
                 }];
                 
                 [elf doneIt];
                 if (completion) completion(error == nil, NO, entities);
             }];
             
             if ([App reachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                 [elf doneIt];
                 if (completion) completion(NO, NO, nil);
             }
             else {
                 [[Api slowApi] enqueueOperation:uploadOperation];
             }
             
         }];

    } onExpiration:^{
        PNLOG(@"background.task.expired.uploadVideoToGroups");
        if (completion) completion(NO, NO, nil);
    }];

}

+ (void)uploadPhoto:(UIImage*)image
         andOverlay:(UIImage*)overlayImage
           toGroups:(NSArray*)groups
         withParams:(NSDictionary*)extraParams
      andCompletion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion {

    if (!groups.count) {
        if (completion) completion(YES,NO, nil);
        return;
    }

    NSString* placeholderId = [NSString stringWithFormat:@"%@%@", [App userId], [NSString randomStringOfLength:32]];
    NSDictionary* originalMetadata = extraParams[@"metadata"] ?: @{};
    NSMutableDictionary* metadata = [originalMetadata mutableCopy];
    [metadata setObject:placeholderId forKey:@"placeholder"];
    __block NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                             encoding:NSUTF8StringEncoding];

    PNLOG(@"group.send_photo");
    [PNBackgroundTaskElf
     doIt:^(PNBackgroundTaskElf *elf) {
         NSMutableArray* groupIds = [NSMutableArray arrayWithCapacity:groups.count];
         NSMutableArray* oneToOneIds = [NSMutableArray arrayWithCapacity:groups.count];
         NSMutableArray* recipients = [NSMutableArray arrayWithCapacity:groups.count];

         for (Group* group in groups) {
             if ([group isGroupValue])
                 [groupIds addObject:group.id];
             else {
                 [oneToOneIds addObject:group.id];
                 [recipients addObject:group.other_user];
             }
         };

         NSData* mediaData = UIImageJPEGRepresentation([image reorientedImage], 0.8);
         NSData* overlayData = overlayImage ? UIImagePNGRepresentation(overlayImage) : nil;

         NSMutableDictionary *params = [@{ @"group_ids" : [groupIds componentsJoinedByString:@","],
                                           @"one_to_one_ids" : [oneToOneIds componentsJoinedByString:@","],
                                           //                                          @"expires_in" : @(86400*30)
                                           @"client_metadata" : metadataString
                                           } mutableCopy];
         if (extraParams) [params addEntriesFromDictionary:extraParams];

         SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/messages/create"
                                                              parameters:params
                                                                    data:mediaData
                                                               dataParam:@"attachment_file"
                                                            dataMimeType:@"image/jpeg"
                                                                   data2:overlayData
                                                              data2Param:@"attachment_overlay_file"
                                                           data2MimeType:@"image/png"
                                ];

         // Create placeholder(s)
         if (upload) {
             SnapCache* cache = [SnapCache shared];
             NSString* imageKey = [NSString stringWithFormat:@"%@_image.jpeg", placeholderId];
             NSString* overlayKey = [NSString stringWithFormat:@"%@_overlay.png", placeholderId];
             [cache setData:mediaData forKey:imageKey];
             if (overlayData) [cache setData:overlayData forKey:overlayKey];

             for (Group* group in groups) {
                 SkyMessage *message = [SkyMessage findOrCreateById:placeholderId inContext:group.managedObjectContext];
                 message.is_placeholderValue = YES;
                 message.user_id = [App userId];
                 message.user = [User me];
                 message.group = group;
                 message.created_at = [NSDate date];
                 message.rankValue = group.max_rankValue+1;
                 message.attachment_url = [[cache urlForKey:imageKey] absoluteString];
                 message.attachment_overlay_url = overlayData ? [[cache urlForKey:overlayKey] absoluteString] : nil;
                 message.attachment_type = @"image";
                 message.attachment_content_type = @"image/jpeg";
                 message.attachment_preview_url = message.attachment_url;
                 message.attachment_preview_width = @(image.size.width);
                 message.attachment_preview_height = @(image.size.height);

                 [message.saved_requestsSet addObject:upload];
                 upload.placeholder = message;
             }

             [[[groups firstObject] managedObjectContext] saveToRootWithCompletion:nil];

         }

         AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {

             SkyMessage* message = [[entities setOfClass:[SkyMessage class]] anyObject];
             [message fetchImageWithCompletion:nil];

             [message.managedObjectContext performBlock:^{
                 message.group.updated_at = [NSDate date];
                 [message.group save];
             }];

             [elf doneIt];
             if (completion) completion(error == nil, NO, entities);
         }];

         if ([App reachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
             [elf doneIt];
             if (completion) completion(NO, NO, nil);
         }
         else {
             [[Api sharedApi] enqueueOperation:uploadOperation];
         }
     }
     onExpiration:^{
         PNLOG(@"background.task.expired.uploadPhoto:toGroups:withParams:andCompletion:");
         if (completion) completion(NO, NO, nil);
     }];

}

- (void)insertPlaceholderMessageWithId:(NSString*)placeholderId constructingWithBlock:(void (^)(SkyMessage* message))block{
    [self.managedObjectContext performBlockAndWait:^{
        
        NSDate* now = [NSDate date];
        SkyMessage *message = [SkyMessage findOrCreateById:placeholderId inContext:self.managedObjectContext];
        message.is_placeholderValue = YES;
        message.group = self;
        message.user = [User meInContext:self.managedObjectContext];
        message.created_at = now;
        message.viewed_at = now;
        message.rankValue = self.last_message.rankValue;
        if (block) block(message);

        if(!self.last_message_at || message.created_at > self.last_message_at)
            self.last_message_at = message.created_at;

        if(!self.last_received_message_at || message.created_at > self.last_received_message_at)
            self.last_received_message_at = message.created_at;
    }];
}

- (NSSet*)otherMembers {
    return [self.members filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![(User*)evaluatedObject isMe];
    }]];
}

- (NSString*)displayName {
    User* user = [self.otherMembers anyObject];
    return user.displayName;
}

- (User*)memberWithUsername:(NSString*)name {
    return [[self.members filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[(User*)evaluatedObject username] isEqualToString:name];
    }]] anyObject];
}

- (BOOL)isDeleted {
    return ((self.last_deleted_rankValue >= self.max_rankValue) || (self.deleted_at && self.last_received_message_at && [self.deleted_at timeIntervalSinceDate:self.last_received_message_at] > 0));
}

@end