
/*
 Notes:

 attachment_url may be either an image or video
 attachment_local_url is a local copy of the media found at attachment_url
 attachment_local_preview_url is of the same media type as attachment_url, reduced in size

 attachment_preview_url is always an image (JPG, PNG, or GIF, possibly animated)

*/

#import "_SkyMessage.h"

extern const CGFloat kSkyMessageImagePreviewDim;
extern const CGFloat kSkyMessageVideoPreviewDim;

@interface SkyMessage : _SkyMessage {}

+(NSDataDetector*) linkDetector;
+(void) prunePlaceholders;

- (dispatch_queue_t) fetchMediaQueue;
- (dispatch_queue_t) videoResampleQueue;

- (BOOL)isExpired;

- (void)fetchVideoWithCompletion:(void (^)(NSURL* fileUrl))completion;
- (void)fetchImageWithCompletion:(void (^)(UIImage* image))completion;
- (void)fetchImagePreviewWithCompletion:(void (^)(UIImage* image))completion;
- (void)fetchVideoPreviewWithCompletion:(void (^)(NSURL *))completion;
- (void)fetchOverlayWithCompletion:(void (^)(UIImage* image))completion;
- (void)fetchMediaWithCompletion:(void (^)(UIImage* photo, NSURL* videoUrl, UIImage* overlay))completion;

// Compose overlay onto photo or video
- (void)fetchCompositeMediaWithCompletion:(void (^)(UIImage* photo, NSURL* videoUrl))completion;

- (BOOL)hasVideo;
- (BOOL)hasImage;
- (BOOL)hasAudio;

- (BOOL)hasAttachment;
- (BOOL)hasText;

- (void)cancelMediaFetch;

- (NSAttributedString*)attributedText;
- (NSDictionary*)attachmentInfo;
- (NSDictionary*)clientMetadata;

- (BOOL)isNew;
- (BOOL)isMeta;

- (void)likeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion;
- (void)unlikeWithCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion;
- (void)didExportWithMethod:(NSString*)exportMethod andCompletion:(void (^)(NSSet *entities, id responseObject, NSError *error))completion;

- (void)markViewed;

- (void)verifyLocalUrls;
- (void)deletePlaceholders;

@end