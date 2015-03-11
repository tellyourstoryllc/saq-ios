#import "_Story.h"
#import "Api.h"

@interface Story : _Story {}

@property (readonly) BOOL isPublic;
@property (readonly) BOOL isFriends;
@property (readonly) BOOL isPrivate;

// Publish compresses video and detects faces before uploading.
+ (void)publishVideo:(NSURL*)videoUrl
             orImage:(UIImage*)image
         withOverlay:(UIImage*)overlayImage
              params:(NSDictionary*)params
          completion:(void (^)(Story* newStory))completion;

+ (void)uploadVideo:(NSURL*)videoUrl
         andOverlay:(UIImage*)overlayImage
         withParams:params
      andCompletion:(void (^)(Story* newStory))completion;

+ (void)uploadPhoto:(UIImage*)image
         andOverlay:(UIImage*)overlayImage
         withParams:params
      andCompletion:(void (^)(Story* newStory))completion;

+ (void)insertPlaceholderWithId:(NSString*)placeholderId
          constructingWithBlock:(void (^)(Story* story))block;

+ (void)prune;

- (void)fetchMediaWithCompletion:(void (^)(UIImage* photo, NSURL* videoUrl, UIImage* videoOverlay))completion;

- (void)apiFlagWithReason:(NSString*)reasonId andCompletion:(ApiRequestCallback)callback;

@end
