#import <AssetsLibrary/AssetsLibrary.h>

#import "Story.h"
#import "SDWebImageManager.h"
#import "Api.h"
#import "App.h"
#import "NSDictionary+RemoveNSNull.h"
#import "LikeOverlayView.h"
#import "SavedApiRequest.h"
#import "PNBackgroundTaskElf.h"
#import "PNVideoComposer.h"
#import "PNFaceDetector.h"
#import "PNVideoCompressor.h"

@interface Story ()
@end

@implementation Story

-(void)awakeFromRemoteWithJson:(id)jsonWithNulls context:(NSManagedObjectContext *)moc {

    // note: does NOT call superclass (SkyMessage's) implementation of this method.

    NSDictionary* json = [(NSDictionary*)jsonWithNulls dictionaryWithoutNSNullValues];

    // User
    id user_id = [json objectForKey:@"actor_id"] ?: [json objectForKey:@"user_id"];
    if(user_id && !self.user)
        self.user = [[User findByIds:@[user_id] inContext:moc] firstObject];

    // Attachment type
    if(self.attachment_content_type)
        self.attachment_type = [[self.attachment_content_type componentsSeparatedByString:@"/"] objectAtIndex:0];

    // Fix busted created_at
    if ([self.created_at timeIntervalSinceNow] > 30000000) {
        NSTimeInterval correctedInterval = [self.created_at timeIntervalSince1970] / 1000;
        self.created_at = [NSDate dateWithTimeIntervalSince1970:correctedInterval];
    }

    if (!self.expires_at) {
        NSTimeInterval five_minutes = 5*60;
        self.expires_at = [NSDate dateWithTimeIntervalSinceNow:five_minutes];
    }

    // Delete placeholder
    [self deletePlaceholders];

    // Update last_story_at of User
    [self.user updateIfLastStory:self];

}

+ (void)publishVideo:(NSURL*)videoUrl
             orImage:(UIImage*)image
         withOverlay:(UIImage*)overlayImage
              params:(NSDictionary*)params
          completion:(void (^)(Story* newStory))completion {

    NSMutableDictionary* newParams = [params mutableCopy];

    if (videoUrl) {
        __block EGOCache* cache = [EGOCache globalCache];
        __block NSString* cacheKey = videoUrl.lastPathComponent;
        [cache moveFileUrl:videoUrl asKey:cacheKey];
        __block NSURL* cacheUrl = [cache urlForKey:cacheKey];
        [cache waitForDisk];

        [[PNFaceDetector new] detectFaceInUIImage:image withCompletion:^(BOOL result) {
            if (result) [newParams setValue:@"yes" forKey:@"has_face"];

            [PNVideoCompressor compressVideoUrl:cacheUrl
                                         preset:AVAssetExportPresetLowQuality
                                       filetype:AVFileTypeMPEG4
                                     exportWith:^(AVAssetExportSession *exportSession) {
                                         // Skip the first 0.2s to avoid possible black frame.
                                         exportSession.timeRange = CMTimeRangeMake(CMTimeMake(2, 10), kCMTimePositiveInfinity);
                                     }
                                 withCompletion:^(NSURL *compressedVideoUrl, NSError *error) {
                                     [cache removeCacheForKey:cacheKey];

                                     [self uploadVideo:compressedVideoUrl
                                            andOverlay:overlayImage
                                            withParams:params
                                         andCompletion:^(Story *newStory) {
                                             [[NSFileManager defaultManager] removeItemAtURL:compressedVideoUrl error:nil];
                                             if (completion) completion(newStory);
                                         }];
                                 }];
        }];
    }
    else {
        [[PNFaceDetector new] detectFaceInUIImage:image withCompletion:^(BOOL result) {
            if (result)
                [newParams setValue:@"yes" forKey:@"has_face"];

            [self uploadPhoto:image
                   andOverlay:overlayImage
                   withParams:newParams
                andCompletion:completion];
        }];
    }
}

+ (void)uploadPhoto:(UIImage*)image
         andOverlay:(UIImage*)overlayImage
         withParams:extraParams
      andCompletion:(void (^)(Story* newStory))completion {

    PNLOG(@"story.upload_photo");

    NSString* placeholderId = [NSString stringWithFormat:@"%@%@", [App userId], [NSString randomStringOfLength:32]];
    NSDictionary* originalMetadata = extraParams[@"metadata"] ?: @{};
    NSMutableDictionary* metadata = [originalMetadata mutableCopy];
    [metadata setObject:placeholderId forKey:@"placeholder"];
    __block NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                             encoding:NSUTF8StringEncoding];
    void (^completionBlock)(Story*) = ^(Story* story) {
        if (completion) completion(story);
    };

    [PNBackgroundTaskElf doIt:^(PNBackgroundTaskElf *elf) {

        NSData* mediaData = UIImageJPEGRepresentation([image reorientedImage], 0.8);

        NSMutableDictionary *params = [@{ @"create_story" : @(YES)
                                          } mutableCopy];

        if (extraParams) [params addEntriesFromDictionary:extraParams];
        params[@"story_creator_id"] = params[@"story_creator_id"] ?: [[User me] id];
        params[@"client_metadata"] = metadataString;

        NSData* overlayData = overlayImage ? UIImagePNGRepresentation(overlayImage) : nil;

        __block SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/messages/create"
                                                             parameters:params
                                                                   data:mediaData
                                                              dataParam:@"attachment_file"
                                                           dataMimeType:@"image/jpeg"
                                                                  data2:overlayData
                                                             data2Param:@"attachment_overlay_file"
                                                          data2MimeType:@"image/png"
                                       ];

        // Create placeholder
        if (upload) {
            SnapCache* cache = [SnapCache shared];
            NSString* imageKey = [NSString stringWithFormat:@"%@_image.jpeg", placeholderId];
            NSString* overlayKey = [NSString stringWithFormat:@"%@_overlay.png", placeholderId];
            [cache setData:mediaData forKey:imageKey];
            if (overlayData) [cache setData:overlayData forKey:overlayKey];

            Story* placeholder = [Story findOrCreateById:placeholderId inContext:[App moc]];
            placeholder.is_placeholderValue = YES;
            placeholder.user_id = [App userId];
            placeholder.user = [User me];
            placeholder.created_at = [NSDate date];
            placeholder.attachment_url = [[cache urlForKey:imageKey] absoluteString];
            placeholder.attachment_overlay_url = overlayData ? [[cache urlForKey:overlayKey] absoluteString] : nil;
            placeholder.attachment_type = @"image";
            placeholder.attachment_content_type = @"image/jpeg";
            placeholder.attachment_preview_url = placeholder.attachment_url;
            placeholder.attachment_preview_width = @(image.size.width);
            placeholder.attachment_preview_height = @(image.size.height);

            placeholder.permission = params[@"permission"];
            [placeholder.saved_requestsSet addObject:upload];
            upload.placeholder = placeholder;
            [placeholder save];
        }

        PNLOG(@"background.task.begin.storyUploadPhoto");

        NSLog(@"starting photo upload task for %@", upload.id);

        AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {

            Story* story = [[entities setOfClass:[Story class]] anyObject];

            [elf doneIt];
            completionBlock(story);
            NSLog(@"completing photo upload task for %@ -> %@", upload.id, story);
            PNLOG(@"background.task.complete.storyUploadPhoto");
        }];

        if ([App reachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
            [elf doneIt];
            completionBlock(nil);
        }
        else {
            [[Api slowApi] enqueueOperation:uploadOperation];
        }
        
    } onExpiration:^{
        completionBlock(nil);
        PNLOG(@"background.task.expired.storyUploadPhoto");
    }];
}

+ (void)uploadVideo:(NSURL*)videoUrl
         andOverlay:(UIImage*)overlayImage
         withParams:extraParams
      andCompletion:(void (^)(Story* newStory))completion {

    PNLOG(@"story.upload_video");

    NSString* placeholderId = [NSString stringWithFormat:@"%@%@", [App userId], [NSString randomStringOfLength:32]];
    NSDictionary* originalMetadata = extraParams[@"metadata"] ?: @{};
    NSMutableDictionary* metadata = [originalMetadata mutableCopy];
    [metadata setObject:placeholderId forKey:@"placeholder"];
    __block NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                     encoding:NSUTF8StringEncoding];

    void (^completionBlock)(Story*) = ^(Story* story) {
        if (completion) completion(story);
    };

    [PNBackgroundTaskElf doIt:^(PNBackgroundTaskElf *elf) {

        NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:[videoUrl path]];
        if (!mediaData) {
            NSLog(@"Failed to load video at path %@", videoUrl.path);
            completionBlock(nil);
            [elf doneIt];
            return;
        }

        [PNVideoComposer fetchScreenshotForVideoUrl:videoUrl atTime:0.1 completion:^(UIImage *screenshot, Float64 actualTime) {

            NSMutableDictionary *params = [@{ @"create_story" : @(YES)
                                              } mutableCopy];
            if (extraParams) [params addEntriesFromDictionary:extraParams];
            params[@"story_creator_id"] = params[@"story_creator_id"] ?: [[User me] id];
            params[@"client_metadata"] = metadataString;

            NSLog(@"uploading story video %@ with params %@", videoUrl, params);

            NSData* overlayData = overlayImage ? UIImagePNGRepresentation(overlayImage) : nil;

            __block SavedApiRequest* upload = [SavedApiRequest storeRequestWithPath:@"/messages/create"
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

                Story* placeholder = [Story findOrCreateById:placeholderId inContext:[App moc]];
                placeholder.is_placeholderValue = YES;
                placeholder.user_id = [App userId];
                placeholder.user = [User me];
                placeholder.created_at = [NSDate date];
                placeholder.attachment_url = [[NSURL fileURLWithPath:upload.data_filepath] absoluteString];
                placeholder.attachment_overlay_url = overlayData ? [[cache urlForKey:overlayKey] absoluteString] : nil;
                placeholder.attachment_type = @"video";
                placeholder.attachment_content_type = @"video/mp4";
                placeholder.attachment_preview_url = previewData ? [[cache urlForKey:ssKey] absoluteString] : nil;
                placeholder.attachment_preview_width = @(screenshot.size.width);
                placeholder.attachment_preview_height = @(screenshot.size.height);
                placeholder.permission = params[@"permission"];

                [placeholder.saved_requestsSet addObject:upload];
                upload.placeholder = placeholder;
                [placeholder save];
            }

            PNLOG(@"background.task.begin.storyUploadVideo");
            NSLog(@"starting video upload task for %@", upload.id);

            AFHTTPRequestOperation* uploadOperation = [upload requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {

                Story* story = [[entities setOfClass:[Story class]] anyObject];
                [story.managedObjectContext performBlockAndWait:^{
                    story.user.updated_at = [NSDate date];
                    [story.managedObjectContext save:nil];
                }];

                completionBlock(story);
                NSLog(@"completing video upload task for %@ -> %@", upload.id, story);
                [elf doneIt];
                PNLOG(@"background.task.complete.storyUploadVideo");
            }];
            
            if ([App reachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                completionBlock(nil);
                [elf doneIt];
            }
            else {
                [[Api slowApi] enqueueOperation:uploadOperation];
            }
            
        }];
        
    } onExpiration:^{
        PNLOG(@"background.task.expired.storyUploadVideo");
        // completionBlock(nil);
    }];
}

+ (void)insertPlaceholderWithId:(NSString*)placeholderId constructingWithBlock:(void (^)(Story* story))block{
    NSManagedObjectContext* moc = [App privateManagedObjectContext];
    [moc performBlockAndWait:^{

        NSDate* now = [NSDate date];
        User* me = [User meInContext:moc];
        Story* story = [Story findOrCreateById:placeholderId inContext:moc];
        story.is_placeholderValue = YES;
        story.user = me;
        story.created_at = now;
        story.viewed_at = now;
        story.rankValue = me.last_story.rankValue;
        if (block) block(story);

        if (!me.last_story_at || ([now timeIntervalSinceDate:me.last_story_at] > 0)) {
            me.last_story_at = now;
            me.last_story = story;
        }

        [moc save:nil];
    }];
}

+ (void)prune {
    NSManagedObjectContext* context = [App privateManagedObjectContext];
    NSArray* expired = [self findAllUsingPredicate:[NSPredicate predicateWithFormat:@"expires_at < %@" argumentArray:@[[NSDate date]]]
                                         inContext:context];
    for (Story* story in expired) {
        [story delete];
    }

    [context saveToRootWithCompletion:nil];
}

- (void)delete {
    User* user = self.user;
    BOOL lastStoryNeedsUpdating = [user.last_story isEqual:self];
    [self destroyAndSave:NO];

    if (lastStoryNeedsUpdating) {
        [user updateLastStory];
    }
}

- (void)obliterate {
    [self.managedObjectContext performBlock:^{
        User* user = self.user;
        __block BOOL lastStoryNeedsUpdating = !user.last_story || [user.last_story isEqual:self];
        self.obliteratedValue = YES;
        [self.managedObjectContext saveToRootWithCompletion:^(BOOL success, NSError *err) {
            if (lastStoryNeedsUpdating) {
                [user updateLastStory];
                [user.managedObjectContext saveToRootWithCompletion:nil];
            }
        }];
    }];
}

- (BOOL)hasVideo {
    return [self.attachment_type isEqualToString:@"video"];
}

- (BOOL)hasImage {
    return [self.attachment_type isEqualToString:@"image"];
}

- (BOOL)isNew {
    if (!self.user.last_seen_story_at) return YES;
    return [self.created_at timeIntervalSinceDate:self.user.last_seen_story_at] > 1; // <-- set to 1s instead of 0 because dates will not be *exactly* the same.
}

- (void)fetchMediaWithCompletion:(void (^)(UIImage* photo, NSURL* videoUrl, UIImage* videoOverlay))completion {

    // If a local file url exists, check to make sure file exists and load it from there..
    [self verifyLocalUrls];

    __weak Story* weakSelf = self;
    dispatch_async(self.fetchMediaQueue, ^{
        __strong Story* sself = weakSelf;

//    __block StoryID* objId = self.objectID;
//    dispatch_async(self.fetchMediaQueue, ^{
//        __strong Story* sself = (Story*)[[App privateManagedObjectContext] objectWithID:objId];


        if (sself.attachment_local_url) {

            [sself fetchOverlayWithCompletion:^(UIImage *overlay) {

                if (completion) {
                    NSURL* filepath = [NSURL URLWithString:sself.attachment_local_url];
                    if (sself.hasVideo) {
                        completion(nil, filepath, overlay);
                        return;
                    }
                    else if (sself.hasImage) {
                        completion([UIImage imageWithContentsOfFile:filepath.path], nil, overlay);
                        return;
                    }
                }
            }];
        }

        else if (sself.attachment_url) {

            if (sself.hasImage) {
                [sself fetchImageWithCompletion:^(UIImage *image) {
                    [sself fetchOverlayWithCompletion:^(UIImage *overlay) {
                        if (completion)
                            completion(image, nil, overlay);
                    }];
                }];
            }
            else if (sself.hasVideo) {
                [sself fetchVideoWithCompletion:^(NSURL *fileUrl) {
                    [sself fetchOverlayWithCompletion:^(UIImage *overlay) {
                        if (completion)
                            completion(nil, fileUrl, overlay);
                    }];
                }];
            }
            else {
                NSLog(@"ERROR: Unknown attachment type! story %@", sself.id);
                if (completion)
                    completion(nil, nil, nil);
            }
        }
        else {
            [sself delete];
            if (completion)
                completion(nil, nil, nil);
        }
    });
}

#pragma mark Liking

- (void)likeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion {
    if (self.likedValue) {
        if (completion) completion(nil, nil, nil);
    }
    else {
        [self.managedObjectContext performBlock:^{
            self.likedValue = YES;
            [self.managedObjectContext save:nil];
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/like", self.id]
                           parameters:nil
                             callback:completion];
        }];
    }
}

- (void)unlikeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion {
    //    [self.managedObjectContext performBlockAndWait:^{
    //        self.likedValue = NO;
    //        [self save];
    //    }];
    if (completion) completion(nil, nil, nil);
}

- (void)markViewed {

    User* user = self.user;
    if (!user.last_seen_story_at) {
        user.last_seen_story_at = self.created_at;
        self.viewedValue = YES;
    }
    else {
        if ([user.last_seen_story_at timeIntervalSinceDate:self.created_at] < 0) {
            user.last_seen_story_at = self.created_at;
            self.viewedValue = YES;
        }
    }
}

- (BOOL)isPublic {
    return [self.permission isEqualToString:@"public"];
}

- (BOOL)isFriends {
    return [self.permission isEqualToString:@"friends"];
}

- (BOOL)isPrivate {
    return [self.permission isEqualToString:@"private"];
}

- (void)apiFlagWithReason:(NSString*)reasonId andCompletion:(ApiRequestCallback)callback {
    [[Api sharedApi] postPath:[NSString stringWithFormat:@"/stories/%@/flag", self.id]
                   parameters:@{@"flag_reason_id":reasonId}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         [self obliterate];
                         if (callback) callback(entities, responseObject, error);
                     }];
}

@end
