// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Group.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct GroupAttributes {
	__unsafe_unretained NSString *avatar_url;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *deleted_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isGroup;
	__unsafe_unretained NSString *isHidden;
	__unsafe_unretained NSString *isOneToOne;
	__unsafe_unretained NSString *isVirtualOneToOne;
	__unsafe_unretained NSString *join_url;
	__unsafe_unretained NSString *last_deleted_rank;
	__unsafe_unretained NSString *last_message_at;
	__unsafe_unretained NSString *last_received_message_at;
	__unsafe_unretained NSString *last_seen_at;
	__unsafe_unretained NSString *last_seen_rank;
	__unsafe_unretained NSString *max_rank;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *topic;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *wallpaper_url;
} GroupAttributes;

extern const struct GroupRelationships {
	__unsafe_unretained NSString *admins;
	__unsafe_unretained NSString *last_message;
	__unsafe_unretained NSString *last_nonmeta_message;
	__unsafe_unretained NSString *last_user_message;
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *other_user;
} GroupRelationships;

@class User;
@class SkyMessage;
@class SkyMessage;
@class SkyMessage;
@class User;
@class SkyMessage;
@class User;

@interface GroupID : NSManagedObjectID {}
@end

@interface _Group : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) GroupID* objectID;

@property (nonatomic, strong) NSString* avatar_url;

//- (BOOL)validateAvatar_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* deleted_at;

//- (BOOL)validateDeleted_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isGroup;

@property (atomic) BOOL isGroupValue;
- (BOOL)isGroupValue;
- (void)setIsGroupValue:(BOOL)value_;

//- (BOOL)validateIsGroup:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isHidden;

@property (atomic) BOOL isHiddenValue;
- (BOOL)isHiddenValue;
- (void)setIsHiddenValue:(BOOL)value_;

//- (BOOL)validateIsHidden:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isOneToOne;

@property (atomic) BOOL isOneToOneValue;
- (BOOL)isOneToOneValue;
- (void)setIsOneToOneValue:(BOOL)value_;

//- (BOOL)validateIsOneToOne:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isVirtualOneToOne;

@property (atomic) BOOL isVirtualOneToOneValue;
- (BOOL)isVirtualOneToOneValue;
- (void)setIsVirtualOneToOneValue:(BOOL)value_;

//- (BOOL)validateIsVirtualOneToOne:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* join_url;

//- (BOOL)validateJoin_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* last_deleted_rank;

@property (atomic) int16_t last_deleted_rankValue;
- (int16_t)last_deleted_rankValue;
- (void)setLast_deleted_rankValue:(int16_t)value_;

//- (BOOL)validateLast_deleted_rank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_message_at;

//- (BOOL)validateLast_message_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_received_message_at;

//- (BOOL)validateLast_received_message_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_seen_at;

//- (BOOL)validateLast_seen_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* last_seen_rank;

@property (atomic) int16_t last_seen_rankValue;
- (int16_t)last_seen_rankValue;
- (void)setLast_seen_rankValue:(int16_t)value_;

//- (BOOL)validateLast_seen_rank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* max_rank;

@property (atomic) int16_t max_rankValue;
- (int16_t)max_rankValue;
- (void)setMax_rankValue:(int16_t)value_;

//- (BOOL)validateMax_rank:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* topic;

//- (BOOL)validateTopic:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* wallpaper_url;

//- (BOOL)validateWallpaper_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *admins;

- (NSMutableSet*)adminsSet;

@property (nonatomic, strong) SkyMessage *last_message;

//- (BOOL)validateLast_message:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) SkyMessage *last_nonmeta_message;

//- (BOOL)validateLast_nonmeta_message:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) SkyMessage *last_user_message;

//- (BOOL)validateLast_user_message:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *members;

- (NSMutableSet*)membersSet;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) User *other_user;

//- (BOOL)validateOther_user:(id*)value_ error:(NSError**)error_;

@end

@interface _Group (AdminsCoreDataGeneratedAccessors)
- (void)addAdmins:(NSSet*)value_;
- (void)removeAdmins:(NSSet*)value_;
- (void)addAdminsObject:(User*)value_;
- (void)removeAdminsObject:(User*)value_;

@end

@interface _Group (MembersCoreDataGeneratedAccessors)
- (void)addMembers:(NSSet*)value_;
- (void)removeMembers:(NSSet*)value_;
- (void)addMembersObject:(User*)value_;
- (void)removeMembersObject:(User*)value_;

@end

@interface _Group (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(SkyMessage*)value_;
- (void)removeMessagesObject:(SkyMessage*)value_;

@end

@interface _Group (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAvatar_url;
- (void)setPrimitiveAvatar_url:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSDate*)primitiveDeleted_at;
- (void)setPrimitiveDeleted_at:(NSDate*)value;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIsGroup;
- (void)setPrimitiveIsGroup:(NSNumber*)value;

- (BOOL)primitiveIsGroupValue;
- (void)setPrimitiveIsGroupValue:(BOOL)value_;

- (NSNumber*)primitiveIsHidden;
- (void)setPrimitiveIsHidden:(NSNumber*)value;

- (BOOL)primitiveIsHiddenValue;
- (void)setPrimitiveIsHiddenValue:(BOOL)value_;

- (NSNumber*)primitiveIsOneToOne;
- (void)setPrimitiveIsOneToOne:(NSNumber*)value;

- (BOOL)primitiveIsOneToOneValue;
- (void)setPrimitiveIsOneToOneValue:(BOOL)value_;

- (NSNumber*)primitiveIsVirtualOneToOne;
- (void)setPrimitiveIsVirtualOneToOne:(NSNumber*)value;

- (BOOL)primitiveIsVirtualOneToOneValue;
- (void)setPrimitiveIsVirtualOneToOneValue:(BOOL)value_;

- (NSString*)primitiveJoin_url;
- (void)setPrimitiveJoin_url:(NSString*)value;

- (NSNumber*)primitiveLast_deleted_rank;
- (void)setPrimitiveLast_deleted_rank:(NSNumber*)value;

- (int16_t)primitiveLast_deleted_rankValue;
- (void)setPrimitiveLast_deleted_rankValue:(int16_t)value_;

- (NSDate*)primitiveLast_message_at;
- (void)setPrimitiveLast_message_at:(NSDate*)value;

- (NSDate*)primitiveLast_received_message_at;
- (void)setPrimitiveLast_received_message_at:(NSDate*)value;

- (NSDate*)primitiveLast_seen_at;
- (void)setPrimitiveLast_seen_at:(NSDate*)value;

- (NSNumber*)primitiveLast_seen_rank;
- (void)setPrimitiveLast_seen_rank:(NSNumber*)value;

- (int16_t)primitiveLast_seen_rankValue;
- (void)setPrimitiveLast_seen_rankValue:(int16_t)value_;

- (NSNumber*)primitiveMax_rank;
- (void)setPrimitiveMax_rank:(NSNumber*)value;

- (int16_t)primitiveMax_rankValue;
- (void)setPrimitiveMax_rankValue:(int16_t)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveTopic;
- (void)setPrimitiveTopic:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveWallpaper_url;
- (void)setPrimitiveWallpaper_url:(NSString*)value;

- (NSMutableSet*)primitiveAdmins;
- (void)setPrimitiveAdmins:(NSMutableSet*)value;

- (SkyMessage*)primitiveLast_message;
- (void)setPrimitiveLast_message:(SkyMessage*)value;

- (SkyMessage*)primitiveLast_nonmeta_message;
- (void)setPrimitiveLast_nonmeta_message:(SkyMessage*)value;

- (SkyMessage*)primitiveLast_user_message;
- (void)setPrimitiveLast_user_message:(SkyMessage*)value;

- (NSMutableSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (User*)primitiveOther_user;
- (void)setPrimitiveOther_user:(User*)value;

@end
