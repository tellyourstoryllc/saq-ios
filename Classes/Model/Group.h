#import "_Group.h"

#import "SkyMessage.h"
#import "DeletedGroup.h"

@interface Group : _Group {}

+ (NSRegularExpression*)mentionRegex;
+ (NSString*) oneToOneIdForUser: (User*) user;
+ (NSString*) oneToOneIdForUserId:(NSString*) userId;

@property (nonatomic,readonly) NSString *join_code;
@property (nonatomic,readonly) NSString *channel;
@property (nonatomic,readonly) NSString *path;

@property (nonatomic,readonly) BOOL hasUnreadMessages;
@property (nonatomic,readonly) BOOL isMissingMessages;

+ (NSArray*)activeGroups;

// Is the logged in user an admin?
- (BOOL)isAdmin;
- (BOOL)hasAdmin:(User*)user;

- (BOOL)isMember;
- (BOOL)hasMember:(User*)user;

- (NSSet*)otherMembers;
- (NSString*)displayName;
- (SkyMessage*)lastMessage;
- (SkyMessage*)lastNonMetaMessage;
- (SkyMessage*)lastUserMessage;
- (SkyMessage*)lastOtherUserMessage;
- (void) updateLastMessage;

- (void)loadMessagesWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion;
- (void)markReadWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion;
- (void)markDeletedWithCompletion:(void (^)(NSSet* entities, id responseObject, NSError* error))completion;

// Find a user based on username. nil if not found
- (User*)memberWithUsername:(NSString*)name;

// Methods for uploading a video to a group (incl 1:1's)

// Publish compresses video before uploading.
+ (void)publishVideo:(NSURL*)videoUrl
             orImage:(UIImage*)image
         withOverlay:(UIImage*)overlayImage
            toGroups:(NSArray*)groups
              params:(NSDictionary*)params
          completion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion;

+ (void)uploadVideo:(NSURL*)videoUrl
         andOverlay:(UIImage*)overlayImage
           toGroups:(NSArray*)groups
         withParams:(NSDictionary*)extraParams
      andCompletion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion;

+ (void)uploadPhoto:(UIImage*)image
         andOverlay:(UIImage*)overlayImage
           toGroups:(NSArray*)groups
         withParams:(NSDictionary*)extraParams
      andCompletion:(void (^)(BOOL success, BOOL cancelled, NSSet *entities))completion;

- (BOOL)isDeleted;

- (void)insertPlaceholderMessageWithId:(NSString*)placeholderId
                 constructingWithBlock:(void (^)(SkyMessage* message))block;

@end
