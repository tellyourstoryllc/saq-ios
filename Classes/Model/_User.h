// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "Base.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *address_book_name;
	__unsafe_unretained NSString *avatar_url;
	__unsafe_unretained NSString *avatar_video_url;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *facebook_id;
	__unsafe_unretained NSString *friend_code;
	__unsafe_unretained NSString *has_one_to_one;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *idle_duration;
	__unsafe_unretained NSString *idle_start_time;
	__unsafe_unretained NSString *is_blocked;
	__unsafe_unretained NSString *is_communicating;
	__unsafe_unretained NSString *is_contact;
	__unsafe_unretained NSString *is_incoming_friend;
	__unsafe_unretained NSString *is_incoming_ignored;
	__unsafe_unretained NSString *is_outgoing_friend;
	__unsafe_unretained NSString *jsonData;
	__unsafe_unretained NSString *last_seen_story_at;
	__unsafe_unretained NSString *last_story_at;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
	__unsafe_unretained NSString *raw_username;
	__unsafe_unretained NSString *registered;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *status_ordinal;
	__unsafe_unretained NSString *status_text;
	__unsafe_unretained NSString *token;
	__unsafe_unretained NSString *updated_at;
	__unsafe_unretained NSString *username;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *groups_administered;
	__unsafe_unretained NSString *groups_joined;
	__unsafe_unretained NSString *last_story;
	__unsafe_unretained NSString *likes;
	__unsafe_unretained NSString *messages;
} UserRelationships;

@class Group;
@class Group;
@class Story;
@class NSManagedObject;
@class SkyMessage;

@interface UserID : NSManagedObjectID {}
@end

@interface _User : Base {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) UserID* objectID;

@property (nonatomic, strong) NSString* address_book_name;

//- (BOOL)validateAddress_book_name:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* avatar_url;

//- (BOOL)validateAvatar_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* avatar_video_url;

//- (BOOL)validateAvatar_video_url:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* created_at;

//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* email;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* facebook_id;

//- (BOOL)validateFacebook_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* friend_code;

//- (BOOL)validateFriend_code:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* has_one_to_one;

@property (atomic) BOOL has_one_to_oneValue;
- (BOOL)has_one_to_oneValue;
- (void)setHas_one_to_oneValue:(BOOL)value_;

//- (BOOL)validateHas_one_to_one:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* id;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* idle_duration;

@property (atomic) int32_t idle_durationValue;
- (int32_t)idle_durationValue;
- (void)setIdle_durationValue:(int32_t)value_;

//- (BOOL)validateIdle_duration:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* idle_start_time;

@property (atomic) int64_t idle_start_timeValue;
- (int64_t)idle_start_timeValue;
- (void)setIdle_start_timeValue:(int64_t)value_;

//- (BOOL)validateIdle_start_time:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_blocked;

@property (atomic) BOOL is_blockedValue;
- (BOOL)is_blockedValue;
- (void)setIs_blockedValue:(BOOL)value_;

//- (BOOL)validateIs_blocked:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_communicating;

@property (atomic) BOOL is_communicatingValue;
- (BOOL)is_communicatingValue;
- (void)setIs_communicatingValue:(BOOL)value_;

//- (BOOL)validateIs_communicating:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_contact;

@property (atomic) BOOL is_contactValue;
- (BOOL)is_contactValue;
- (void)setIs_contactValue:(BOOL)value_;

//- (BOOL)validateIs_contact:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_incoming_friend;

@property (atomic) BOOL is_incoming_friendValue;
- (BOOL)is_incoming_friendValue;
- (void)setIs_incoming_friendValue:(BOOL)value_;

//- (BOOL)validateIs_incoming_friend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_incoming_ignored;

@property (atomic) BOOL is_incoming_ignoredValue;
- (BOOL)is_incoming_ignoredValue;
- (void)setIs_incoming_ignoredValue:(BOOL)value_;

//- (BOOL)validateIs_incoming_ignored:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_outgoing_friend;

@property (atomic) BOOL is_outgoing_friendValue;
- (BOOL)is_outgoing_friendValue;
- (void)setIs_outgoing_friendValue:(BOOL)value_;

//- (BOOL)validateIs_outgoing_friend:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSData* jsonData;

//- (BOOL)validateJsonData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_seen_story_at;

//- (BOOL)validateLast_seen_story_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_story_at;

//- (BOOL)validateLast_story_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* priority;

@property (atomic) int16_t priorityValue;
- (int16_t)priorityValue;
- (void)setPriorityValue:(int16_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* raw_username;

//- (BOOL)validateRaw_username:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* registered;

@property (atomic) BOOL registeredValue;
- (BOOL)registeredValue;
- (void)setRegisteredValue:(BOOL)value_;

//- (BOOL)validateRegistered:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* status_ordinal;

@property (atomic) int32_t status_ordinalValue;
- (int32_t)status_ordinalValue;
- (void)setStatus_ordinalValue:(int32_t)value_;

//- (BOOL)validateStatus_ordinal:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* status_text;

//- (BOOL)validateStatus_text:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* token;

//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* updated_at;

//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *groups_administered;

- (NSMutableSet*)groups_administeredSet;

@property (nonatomic, strong) NSSet *groups_joined;

- (NSMutableSet*)groups_joinedSet;

@property (nonatomic, strong) Story *last_story;

//- (BOOL)validateLast_story:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *likes;

- (NSMutableSet*)likesSet;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@end

@interface _User (Groups_administeredCoreDataGeneratedAccessors)
- (void)addGroups_administered:(NSSet*)value_;
- (void)removeGroups_administered:(NSSet*)value_;
- (void)addGroups_administeredObject:(Group*)value_;
- (void)removeGroups_administeredObject:(Group*)value_;

@end

@interface _User (Groups_joinedCoreDataGeneratedAccessors)
- (void)addGroups_joined:(NSSet*)value_;
- (void)removeGroups_joined:(NSSet*)value_;
- (void)addGroups_joinedObject:(Group*)value_;
- (void)removeGroups_joinedObject:(Group*)value_;

@end

@interface _User (LikesCoreDataGeneratedAccessors)
- (void)addLikes:(NSSet*)value_;
- (void)removeLikes:(NSSet*)value_;
- (void)addLikesObject:(NSManagedObject*)value_;
- (void)removeLikesObject:(NSManagedObject*)value_;

@end

@interface _User (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(SkyMessage*)value_;
- (void)removeMessagesObject:(SkyMessage*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAddress_book_name;
- (void)setPrimitiveAddress_book_name:(NSString*)value;

- (NSString*)primitiveAvatar_url;
- (void)setPrimitiveAvatar_url:(NSString*)value;

- (NSString*)primitiveAvatar_video_url;
- (void)setPrimitiveAvatar_video_url:(NSString*)value;

- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;

- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;

- (NSString*)primitiveFacebook_id;
- (void)setPrimitiveFacebook_id:(NSString*)value;

- (NSString*)primitiveFriend_code;
- (void)setPrimitiveFriend_code:(NSString*)value;

- (NSNumber*)primitiveHas_one_to_one;
- (void)setPrimitiveHas_one_to_one:(NSNumber*)value;

- (BOOL)primitiveHas_one_to_oneValue;
- (void)setPrimitiveHas_one_to_oneValue:(BOOL)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSNumber*)primitiveIdle_duration;
- (void)setPrimitiveIdle_duration:(NSNumber*)value;

- (int32_t)primitiveIdle_durationValue;
- (void)setPrimitiveIdle_durationValue:(int32_t)value_;

- (NSNumber*)primitiveIdle_start_time;
- (void)setPrimitiveIdle_start_time:(NSNumber*)value;

- (int64_t)primitiveIdle_start_timeValue;
- (void)setPrimitiveIdle_start_timeValue:(int64_t)value_;

- (NSNumber*)primitiveIs_blocked;
- (void)setPrimitiveIs_blocked:(NSNumber*)value;

- (BOOL)primitiveIs_blockedValue;
- (void)setPrimitiveIs_blockedValue:(BOOL)value_;

- (NSNumber*)primitiveIs_communicating;
- (void)setPrimitiveIs_communicating:(NSNumber*)value;

- (BOOL)primitiveIs_communicatingValue;
- (void)setPrimitiveIs_communicatingValue:(BOOL)value_;

- (NSNumber*)primitiveIs_contact;
- (void)setPrimitiveIs_contact:(NSNumber*)value;

- (BOOL)primitiveIs_contactValue;
- (void)setPrimitiveIs_contactValue:(BOOL)value_;

- (NSNumber*)primitiveIs_incoming_friend;
- (void)setPrimitiveIs_incoming_friend:(NSNumber*)value;

- (BOOL)primitiveIs_incoming_friendValue;
- (void)setPrimitiveIs_incoming_friendValue:(BOOL)value_;

- (NSNumber*)primitiveIs_incoming_ignored;
- (void)setPrimitiveIs_incoming_ignored:(NSNumber*)value;

- (BOOL)primitiveIs_incoming_ignoredValue;
- (void)setPrimitiveIs_incoming_ignoredValue:(BOOL)value_;

- (NSNumber*)primitiveIs_outgoing_friend;
- (void)setPrimitiveIs_outgoing_friend:(NSNumber*)value;

- (BOOL)primitiveIs_outgoing_friendValue;
- (void)setPrimitiveIs_outgoing_friendValue:(BOOL)value_;

- (NSData*)primitiveJsonData;
- (void)setPrimitiveJsonData:(NSData*)value;

- (NSDate*)primitiveLast_seen_story_at;
- (void)setPrimitiveLast_seen_story_at:(NSDate*)value;

- (NSDate*)primitiveLast_story_at;
- (void)setPrimitiveLast_story_at:(NSDate*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int16_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int16_t)value_;

- (NSString*)primitiveRaw_username;
- (void)setPrimitiveRaw_username:(NSString*)value;

- (NSNumber*)primitiveRegistered;
- (void)setPrimitiveRegistered:(NSNumber*)value;

- (BOOL)primitiveRegisteredValue;
- (void)setPrimitiveRegisteredValue:(BOOL)value_;

- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;

- (NSNumber*)primitiveStatus_ordinal;
- (void)setPrimitiveStatus_ordinal:(NSNumber*)value;

- (int32_t)primitiveStatus_ordinalValue;
- (void)setPrimitiveStatus_ordinalValue:(int32_t)value_;

- (NSString*)primitiveStatus_text;
- (void)setPrimitiveStatus_text:(NSString*)value;

- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;

- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;

- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;

- (NSMutableSet*)primitiveGroups_administered;
- (void)setPrimitiveGroups_administered:(NSMutableSet*)value;

- (NSMutableSet*)primitiveGroups_joined;
- (void)setPrimitiveGroups_joined:(NSMutableSet*)value;

- (Story*)primitiveLast_story;
- (void)setPrimitiveLast_story:(Story*)value;

- (NSMutableSet*)primitiveLikes;
- (void)setPrimitiveLikes:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

@end
