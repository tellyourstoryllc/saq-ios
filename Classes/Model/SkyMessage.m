#import "SkyMessage.h"

#import "App.h"
#import "Api.h"
#import "NSDictionary+RemoveNSNull.h"
#import "SDWebImageManager.h"
#import "EGOCache.h"
#import "PNVideoComposer.h"
#import "PNVideoWatermarker.h"
#import "PNVideoResampler.h"
#import "FastMediaLoader.h"

#import "User.h"
#import "Group.h"
#import "GroupManager.h"
#import "Emoticon.h"
#import "LikeOverlayView.h"

const CGFloat kSkyMessageImagePreviewDim = 400.0f;
const CGFloat kSkyMessageVideoPreviewDim = 400.0f;

@interface SkyMessage()
@property (nonatomic,strong) NSAttributedString* cachedAttributedString;
@end

@implementation SkyMessage

@synthesize cachedAttributedString = _cachedAttributedString;

-(dispatch_queue_t) fetchMediaQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.perceptualnet.skymessage.fetchmedia",  DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

-(dispatch_queue_t) videoResampleQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.perceptualnet.skymessage.video_resample",  DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

-(void)awakeFromRemoteWithJson:(id)jsonWithNulls context:(NSManagedObjectContext *)moc
{

    NSDictionary* json = [(NSDictionary*)jsonWithNulls dictionaryWithoutNSNullValues];

    self.delivered_at = self.delivered_at ?: [NSDate date];

    // User
    id user_id = [json objectForKey:@"actor_id"] ?: [json objectForKey:@"user_id"];
    if(user_id)
        self.user = [[User findByIds:@[user_id] inContext:moc] firstObject];

    // Group
    NSString* groupType = @"groups";
    id group_id = [json objectForKey:@"group_id"];
    if (!group_id) {
        group_id = [json objectForKey:@"one_to_one_id"];
        groupType = @"one_to_ones";
    }

    if(group_id) {
        Group* group = [[Group findByIds:@[group_id] inContext:moc] firstObject];
        if (group)
            self.group = group;
        else {
            NSString* selfId = self.id;
            [[Api sharedApi] postPath:[NSString stringWithFormat:@"/%@/%@", groupType, group_id]
                           parameters:nil
                             callback:^(NSSet *entities, id responseObject, NSError *error) {
                                 SkyMessage* selfish = [[SkyMessage findByIds:@[selfId] inContext:moc] firstObject];
                                 selfish.group = [[Group findByIds:@[group_id] inContext:moc] firstObject];
                                 [moc save:nil];
                                 [[GroupManager manager] updateUnreadCount];
                             }];
        }
    }

    // Attachment type
    if(self.attachment_content_type)
        self.attachment_type = [[self.attachment_content_type componentsSeparatedByString:@"/"] objectAtIndex:0];

    // Link URL
    if(self.text) {
        NSRange range = [[SkyMessage linkDetector] rangeOfFirstMatchInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
        if(range.location != NSNotFound) {
            self.link_url = [self.text substringWithRange:range];
            if([self.link_url rangeOfString:@"://"].location == NSNotFound)
                self.link_url = [NSString stringWithFormat:@"http://%@",self.link_url];
        }
    }

    [self deletePlaceholders];
    
    // Prefetch
//    if (self.attachment_preview_url)
//        [[FastMediaLoader shared] loadImageForUrlString:self.attachment_preview_url withCompletion:nil];

    // Update other messages if necessary
    if ([self.attachment_content_type isEqualToString:@"meta/like"] && self.attachment_message_id && self.user.isMe) {
        SkyMessage* otherMessage = [[SkyMessage findByIds:@[self.attachment_message_id] inContext:moc] lastObject];
        otherMessage.likedValue = YES;
    }

    // Update group as needed:
    if (!self.group.last_message || self.group.last_message.rankValue < self.rankValue)
        [self.group updateLastMessage];

    self.group.last_received_message_at = self.group.last_received_message_at ?: self.created_at;
    if (NSOrderedDescending == [self.created_at compare:self.group.last_received_message_at]) {
        self.group.last_received_message_at = self.created_at;
    }

    self.group.max_rank = self.group.max_rank ?: self.rank;
    self.group.updated_at = [NSDate date];

    if (self.rankValue > self.group.max_rankValue) {
        self.group.max_rank = self.rank;

        if(self.group.last_seen_rankValue == self.rankValue) {
            self.group.last_seen_at = self.created_at;
        }
    }
}

-(void) deletePlaceholders {
    // Delete placeholders
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSString *placeholder_id = self.clientMetadata[@"placeholder"];
    if (placeholder_id) {
        NSArray* placeholders = [[self class] findAllUsingPredicate:[NSPredicate predicateWithFormat:@"id BEGINSWITH %@", placeholder_id ] inContext:moc];
        for (SkyMessage* message in placeholders)
            [moc deleteObject:message];
        if (placeholders.count)
            [moc saveToRootWithCompletion:nil];
    }
}

- (void)prepareForDeletion {
    if (self.group.last_message == self)
        self.group.last_message = nil;

    if (self.group.last_user_message == self)
        self.group.last_user_message = nil;

    if (self.group.last_nonmeta_message == self)
        self.group.last_nonmeta_message = nil;
}

// ===== End parser methods ======================================

+(NSDataDetector*) linkDetector {
    static NSDataDetector *d;
    NSError *error;
    if(!d) {
        d = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];

        if(!d)
            NSLog(@"Error making data detector: %@",error);
    }
    return d;
}

+(void) prunePlaceholders {
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"is_placeholder == YES AND created_at < %@", [NSDate dateWithTimeIntervalSinceNow:-600]];
    NSArray* oldPlaceholders = [self findAllUsingPredicate:pred sortedBy:nil];
    for (SkyMessage* m in oldPlaceholders) {
        [m destroyAndSave:YES];
    }
}

+ (NSOperationQueue*)videoFetchOperationQueue {
    static NSOperationQueue* queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });

    return queue;
}

- (BOOL)isExpired {
    if (self.expires_at) {
        return [self.expires_at timeIntervalSinceNow] < 0;
    }
    return NO;
}

- (BOOL)hasVideo {
    return [self.attachment_type isEqualToString:@"video"];
}

- (BOOL)hasImage {
    return [self.attachment_type isEqualToString:@"image"];
}

- (BOOL)hasAudio {
    return [self.attachment_type isEqualToString:@"audio"];
}

- (BOOL)hasAttachment {
    return self.hasImage || self.hasVideo || self.hasAudio;
}

- (BOOL)hasText {
    return self.text.length > 0;
}

- (BOOL)isMeta {
    return [self.attachment_type isEqualToString:@"meta"];
}

- (BOOL)isNew {
    return self.rankValue > self.group.last_seen_rankValue;
}

- (void)markViewed {
    if (!self.group.last_seen_rank) {
        self.group.last_seen_rankValue = self.rankValue;
        [self.group save];
    }
    else {
        if (self.group.last_seen_rankValue < self.rankValue) {
            self.group.last_seen_rankValue = self.rankValue;
            [self.group save];
        }
    }
}

- (BOOL)isLandscape {
    if (self.attachment_preview_width && self.attachment_preview_height)
        return self.attachment_preview_widthValue > self.attachment_preview_heightValue;
    else
        return NO;
}

- (NSString*)cacheKeyForVideo:(NSURL*)url {
    return [NSString stringWithFormat:@"%@%@.mp4", [url.absoluteString md5], url.absoluteString.lastPathComponent];
}

- (void)fetchVideoWithCompletion:(void (^)(NSURL* fileUrl))completion {

    if (![self hasVideo]) {
        if (completion) completion(nil);
        return;
    }

    NSURL* pl = [NSURL URLWithString:self.attachment_url];

    if ([[pl scheme] isMatchedByRegex:@"https?"]){
        FastMediaLoader* loader = [FastMediaLoader shared];
        [loader loadVideoForUrlString:self.attachment_url withCompletion:completion];
    }
    else if ([[pl scheme] isEqualToString:@"file"]) {
        if (completion)
            completion(pl);
    }
    else {
        if (completion)
            completion(nil);
    }
}

- (void)generateLocalVideoPreviewFromUrl:(NSURL*)videoUrl
                          withCompletion:(void (^)(NSURL* localUrl))completion
{
    if (!videoUrl) {
        if (completion) completion(nil);
        return;
    }

    __block SkyMessage* myself = self;

    dispatch_async(self.videoResampleQueue, ^{
        if (!myself.attachment_local_preview_url) {
            [PNVideoResampler resampleVideoUrl:videoUrl
                                         toFit:YES
                                          size:CGSizeMake(kSkyMessageVideoPreviewDim, kSkyMessageVideoPreviewDim)
                                withCompletion:^(NSURL *resampledVideoUrl, NSError *error) {

                                    // This is the dumbest shit ever.
                                    NSManagedObjectContext* shit = [App privateManagedObjectContext];
                                    SkyMessage* shitself = [SkyMessage findById:myself.id inContext:shit];

                                    if (!error && resampledVideoUrl) {

                                        EGOCache* cache = [EGOCache globalCache];
                                        NSString* cacheKey = [NSString stringWithFormat:@"preview_%@", videoUrl.lastPathComponent];

                                        [cache copyFileUrl:resampledVideoUrl asKey:cacheKey];

                                        NSURL* previewUrl = [cache urlForKey:cacheKey];
                                        shitself.attachment_local_preview_url = [previewUrl absoluteString];
                                        [shit save:nil];

                                        if (completion) completion(previewUrl);
                                    }
                                    else {
                                        NSLog(@"Error generating local preview for %@(%@) from %@. %@", shitself.user.username, shitself.id, videoUrl, error);
                                        if (completion) completion(nil);
                                    }
                                }];
        }
        else {
            if (completion) completion([NSURL URLWithString:myself.attachment_local_preview_url]);
        }
    });
}

- (void)generateLocalImagePreviewFromImage:(UIImage*)image
                            withCompletion:(void (^)(UIImage* preview))completion
{
    if (!image) {
        if (completion) completion(nil);
        return;
    }

    // Write a shrunk version into attachment_local_preview_url
    [self verifyLocalUrls];
    if (self && !self.attachment_local_preview_url) {
        UIImage* previewImage = [image imageByScalingProportionallyToFit:CGSizeMake(kSkyMessageImagePreviewDim, kSkyMessageImagePreviewDim)];
        NSData* previewData = UIImagePNGRepresentation(previewImage);
        EGOCache* cache = [EGOCache globalCache];
        NSString* cacheKey = [NSString stringWithFormat:@"preview_%@.png", self.id];
        [cache setData:previewData forKey:cacheKey completion:^(NSURL *url) {
            NSString* previewUrlString = [url absoluteString];
            [self.managedObjectContext performBlock:^{
                self.attachment_local_preview_url = previewUrlString;
                NSLog(@"writing preview: %@", previewUrlString);
                [self.managedObjectContext save:nil];
                if (completion) completion(previewImage);
            }];
        }];
    }
    else {
        if (completion)
            completion([UIImage imageWithContentsOfFile:[[NSURL URLWithString:self.attachment_local_preview_url] path]]);
    }
}

- (void)fetchImageWithCompletion:(void (^)(UIImage*))completion {
    if (![self hasImage]) {
        if (completion) completion(nil);
        return;
    }

    FastMediaLoader* loader = [FastMediaLoader shared];
    [loader loadImageForUrlString:self.attachment_url withCompletion:completion];
}

- (void)fetchImagePreviewWithCompletion:(void (^)(UIImage*))completion
{
    __weak SkyMessage* weakSelf = self;
    dispatch_async(self.fetchMediaQueue, ^{
        __strong SkyMessage* sself = weakSelf;

        [sself verifyLocalUrls];

        if (sself.attachment_local_preview_url && sself.hasImage) {
            [[FastMediaLoader shared] loadImageForUrlString:sself.attachment_local_preview_url withCompletion:completion];
        }
        else if (sself.attachment_local_url && sself.hasImage) {
            [[FastMediaLoader shared] loadImageForUrlString:sself.attachment_local_url withCompletion:completion];
        }
        else if (sself.attachment_preview_url) {
            [[FastMediaLoader shared] loadImageForUrlString:sself.attachment_preview_url withCompletion:completion];
        }
        else if (sself.attachment_url && sself.hasImage) {
            [[FastMediaLoader shared] loadImageForUrlString:sself.attachment_url withCompletion:completion];
        }
        else {
            if (completion) completion(nil);
        }
    });
}

- (void)fetchMediaWithCompletion:(void (^)(UIImage*, NSURL*, UIImage*))completion
{
    __weak SkyMessage* weakSelf = self;
    dispatch_async(self.fetchMediaQueue, ^{
        __strong SkyMessage* sself = weakSelf;

        if (sself.hasVideo) {
            [sself fetchVideoWithCompletion:^(NSURL *fileUrl) {
                [sself fetchOverlayWithCompletion:^(UIImage *overlay) {
                    if (completion) completion(nil, fileUrl, overlay);
                }];
            }];
        }
        else if (sself.hasImage) {
            [sself fetchImageWithCompletion:^(UIImage *image) {
                [sself fetchOverlayWithCompletion:^(UIImage *overlay) {
                    if (completion) completion(image,nil,overlay);
                }];
            }];
        }
        else {
            if (completion) completion(nil,nil,nil);
        }
    });
}

- (void)fetchVideoPreviewWithCompletion:(void (^)(NSURL *))completion {
    __weak SkyMessage* weakSelf = self;
    dispatch_async(self.fetchMediaQueue, ^{
        __strong SkyMessage* sself = weakSelf;

        [sself verifyLocalUrls];

        if (sself.attachment_local_preview_url && sself.hasVideo) {
            NSURL* pl = [NSURL URLWithString:sself.attachment_local_preview_url];
            if (completion) completion(pl);
        }
        else {
            [self fetchVideoWithCompletion:completion];
        }
    });
}

- (void)fetchOverlayWithCompletion:(void (^)(UIImage*))completion {
    if (!self.attachment_overlay_url && !self.attachment_local_overlay_url) {
        if (completion) completion(nil);
        return;
    }

    NSString* urlString = self.attachment_local_overlay_url ?: self.attachment_overlay_url;
    FastMediaLoader* loader = [FastMediaLoader shared];
    [loader loadImageForUrlString:urlString withCompletion:completion];
}

- (void)fetchCompositeMediaWithCompletion:(void (^)(UIImage*, NSURL*))completion {
    if (!completion) return;
    
    [self fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *overlay) {
        if (overlay) {
            if (photo) {
                UIImage* compositePhoto = [photo overlayImage:overlay
                                                      inFrame:CGRectMake(0, 0, photo.size.width, photo.size.height)
                                                    blendMode:kCGBlendModeNormal
                                                        alpha:1.0];
                completion(compositePhoto,nil);
            }
            else if (videoUrl) {
                [PNVideoWatermarker watermarkVideoUrl:videoUrl
                                                image:overlay
                                              opacity:1.0
                                       withCompletion:^(NSURL *watermarkedVideoUrl, NSError *error) {
                                           completion(nil, videoUrl);
                                       }];
            }
        }
        else {
            completion(photo, videoUrl);
        }
    }];
}

- (void)cancelMediaFetch {
    [[FastMediaLoader shared] cancelRequestForUrlString:self.attachment_url];
    [[FastMediaLoader shared] cancelRequestForUrlString:self.attachment_preview_url];
}

- (void)verifyLocalUrls {

    NSArray* attributes = @[@"attachment_local_url", @"attachment_local_preview_url", @"attachment_local_overlay_url"];

    NSFileManager* fileMan;
    BOOL needSave = NO;

    NSManagedObjectContext* shit;
    SkyMessage* shitSelf;
    SkyMessageID* objId = [self objectID];

    for (NSString* attr in attributes) {
        NSString* val = [self valueForKey:attr];
        if (!val)
            continue;

        fileMan = fileMan ?: [NSFileManager defaultManager];
        NSURL* fileUrl = [NSURL URLWithString:val];
        if (![fileMan isReadableFileAtPath:fileUrl.path]) {
            needSave = YES;

            __weak SkyMessage* weakSelf = self;
            [self.managedObjectContext performBlock:^{
                [weakSelf setValue:nil forKey:attr];
            }];

            // Awful, awful, awful:
            shit = shit ?: [App privateManagedObjectContext];
            shitSelf = shitSelf ?: (SkyMessage*)[shit objectWithID:objId];
            [shitSelf setValue:nil forKey:attr];

            NSLog(@"File not readable: %@", fileUrl.path);
        }
    }

    if (needSave)
        [shit save:nil];
}

-(NSAttributedString*)attributedText {
    if (self.cachedAttributedString) return self.cachedAttributedString;
    if (!self.text) return nil;

    NSMutableAttributedString *text = [Emoticon emoticonStringForString:self.text];
    NSString *plainText = text.string;

    [text addAttribute:NSFontAttributeName value:FONT(16) range:NSMakeRange(0, text.length)];

    if (self.user.isMe)
        [text addAttribute:NSForegroundColorAttributeName value:COLOR(blackColor) range:NSMakeRange(0, text.length)];

    if(self.link_url) {
        NSRange range = [[SkyMessage linkDetector] rangeOfFirstMatchInString:plainText options:0 range:NSMakeRange(0, plainText.length)];
        if(range.location != NSNotFound)
            [text addAttribute:NSForegroundColorAttributeName value:COLOR(blueColor) range:range];
    }

    NSArray *matches = [[Group mentionRegex] matchesInString:plainText options:0 range:NSMakeRange(0, plainText.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match rangeAtIndex:2];
        NSString *potentialUsername = [[plainText substringWithRange:range] lowercaseString];

        // TODO: Use nice UIImage instead
        if ([self.group memberWithUsername:potentialUsername] || [@"all" isEqualToString:potentialUsername]) {
            UIColor *fg;
            UIColor *bg;

            if([[App username] isEqualToString:potentialUsername] || [@"all" isEqualToString:potentialUsername]) {
                bg = COLOR(greenColor);
                fg = COLOR(whiteColor);
            } else {
                bg = COLOR(whiteColor);
                fg = COLOR(blackColor);
            }
            [text addAttribute:NSBackgroundColorAttributeName value:bg range:range];
            [text addAttribute:NSForegroundColorAttributeName value:fg range:range];
        }
    }

    _cachedAttributedString = text;
    return text;
}

- (NSDictionary*)clientMetadata {
    if (self.client_metadata) {
        return [NSJSONSerialization JSONObjectWithData:[self.client_metadata dataUsingEncoding:NSUTF8StringEncoding]
                                               options:0
                                                 error:nil];
    }
    return nil;
}

- (NSDictionary*)attachmentInfo {
    if (self.attachment_metadata) {
        return [NSJSONSerialization JSONObjectWithData:[self.attachment_metadata dataUsingEncoding:NSUTF8StringEncoding]
                                               options:0
                                                 error:nil];
    }
    return nil;
}

#pragma mark Liking messages

- (void)likeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion {
    [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/like", self.id]
                   parameters:nil
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         if (completion) completion(entities, responseObject, error);
                     }];
}

- (void)unlikeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion {
    //    [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/unlike", self.id]
    //                   parameters:nil
    //                     callback:^(NSSet *entities, id responseObject, NSError *error) {
    //                         if (completion) completion(entities, responseObject, error);
    //                     }];
}

// Valid values for exportMethod are "screenshot", "library", and "other"
- (void)didExportWithMethod:(NSString*)exportMethod
              andCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion {
    [[Api sharedApi] postPath:[NSString stringWithFormat:@"/messages/%@/export", self.id]
                   parameters:@{@"method":exportMethod}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         if (completion) completion(entities, responseObject, error);
                     }];
}

@end
