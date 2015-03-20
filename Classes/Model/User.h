#import "_User.h"

#import "Group.h"

@interface User : _User {}
@property (nonatomic,readonly) NSString* mentionName;

+ (User*)me;
+ (User*)meInContext:(NSManagedObjectContext*)moc;
+ (void)fetchUserNamed:(NSString*)name completion:(void (^)(User* user))completion;
+ (void)fetchUserId:(NSString*)userId completion:(void (^)(User* user))completion;
+ (void)fetchUserIds:(NSArray*)idArray completion:(void (^)(NSArray* users))completion;

+ (id)findByUsername:(NSString*)name inContext:(NSManagedObjectContext*)moc;
+ (id)findOrCreateByUsername:(NSString*)name inContext:(NSManagedObjectContext*)moc;

+ (void)fetchFriendsWithCompletion:(void (^)(NSArray* userArray))completion;

- (BOOL)isMe;
- (BOOL)isTemporary; // is this a temp user that exists only on client? (i.e., /contacts/add still needs to be called)

- (NSString *)stringForIdleInterval;

- (Group*)oneToOneGroup;
- (Group*)oneToOneGroupInContext:(NSManagedObjectContext*)moc;

- (NSString*)displayName;
- (NSString*)alternateName;

- (BOOL)hasAvatar;
- (void)fetchAvatarWithCompletion:(void (^)(UIImage* avatarImage))completion;
- (void)killDoppelganger;

- (void)updateLastStory;
- (void)updateIfLastStory:(Story*)story;
- (BOOL)hasUnreadStory;
- (NSArray*)associateWithStories; // Reconcile user with stories with this user_id, but nil user associations.

- (UIColor*)color;

@end